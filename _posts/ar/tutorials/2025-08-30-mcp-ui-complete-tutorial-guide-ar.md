---
title: "دليل MCP-UI الشامل: بناء تجارب واجهة المستخدم من الجيل التالي لوكلاء الذكاء الاصطناعي"
excerpt: "تعلم كيفية إنشاء مكونات واجهة المستخدم التفاعلية لخوادم MCP (Model Context Protocol) باستخدام MCP-UI. دليل شامل مع أمثلة TypeScript و Ruby."
seo_title: "دليل MCP-UI: بناء واجهات وكلاء الذكاء الاصطناعي التفاعلية - دليل شامل"
seo_description: "أتقن تطوير MCP-UI مع هذا الدليل الشامل. تعلم إنشاء مكونات واجهة المستخدم التفاعلية لوكلاء الذكاء الاصطناعي باستخدام TypeScript و Ruby مع أمثلة عملية."
date: 2025-08-30
categories:
  - tutorials
tags:
  - mcp-ui
  - ai-agents
  - typescript
  - ruby
  - user-interface
  - model-context-protocol
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/tutorials/mcp-ui-complete-tutorial-guide/
canonical_url: "https://thakicloud.github.io/ar/tutorials/mcp-ui-complete-tutorial-guide/"
---

⏱️ **وقت القراءة المتوقع**: 15 دقيقة

## مقدمة عن MCP-UI

لقد أحدث بروتوكول سياق النموذج (MCP) ثورة في كيفية تفاعل وكلاء الذكاء الاصطناعي مع الأنظمة الخارجية. ومع ذلك، غالباً ما تقصر التفاعلات التقليدية القائمة على النص عند التعامل مع تصور البيانات المعقد أو سير العمل التفاعلي. هنا يأتي دور **MCP-UI** - وهو SDK رائد يمكّن من إنشاء واجهات مستخدم غنية وتفاعلية داخل خوادم MCP.

يسمح MCP-UI للمطورين بإنشاء مكونات واجهة مستخدم ديناميكية يمكن عرضها مباشرة في العملاء المتوافقين مع MCP، مما يوفر للمستخدمين واجهات بصرية بديهية للعمليات المعقدة. سواء كنت تبني لوحات معلومات للبيانات أو واجهات نماذج أو تصورات تفاعلية، فإن MCP-UI يسد الفجوة بين وكلاء الذكاء الاصطناعي والواجهات الصديقة للمستخدم.

## ما هو MCP-UI؟

MCP-UI هو SDK مفتوح المصدر يوسع بروتوكول سياق النموذج لدعم مكونات واجهة المستخدم الغنية. يمكّن خوادم MCP من إرجاع ليس فقط استجابات نصية، بل عناصر واجهة مستخدم تفاعلية بالكامل يمكن عرضها في العملاء المتوافقين.

### الميزات الرئيسية

- **أنواع محتوى متعددة**: دعم لـ HTML الخام والروابط الخارجية ومكونات DOM البعيدة
- **مرونة الإطار**: يعمل مع React و Web Components و JavaScript العادي
- **الأمان أولاً**: يتم تشغيل جميع محتويات واجهة المستخدم في إطارات iframe معزولة لأقصى درجات الأمان
- **الإجراءات التفاعلية**: يمكن لمكونات واجهة المستخدم تشغيل استدعاءات الأدوات والتفاعل مع الوكيل
- **متعدد المنصات**: متوافق مع عدة مضيفين لـ MCP بما في ذلك Postman و Goose و Smithery

### نظرة عامة على البنية

يتبع MCP-UI بنية العميل-الخادم حيث:

1. **جانب الخادم**: ينشئ موارد واجهة المستخدم باستخدام SDK خادم MCP-UI
2. **جانب العميل**: يعرض موارد واجهة المستخدم باستخدام عارض عميل MCP-UI
3. **التواصل**: يتم توصيل إجراءات واجهة المستخدم مرة أخرى إلى الخادم عبر الأحداث

## التثبيت والإعداد

### المتطلبات المسبقة

قبل البدء، تأكد من وجود:
- Node.js 16+ (لتطوير TypeScript)
- Ruby 3.0+ (لتطوير Ruby)
- فهم أساسي لمفاهيم MCP
- إلمام بـ React أو Web Components

### تثبيت TypeScript

```bash
# استخدام npm
npm install @mcp-ui/server @mcp-ui/client

# استخدام pnpm
pnpm add @mcp-ui/server @mcp-ui/client

# استخدام yarn
yarn add @mcp-ui/server @mcp-ui/client
```

### تثبيت Ruby

```bash
gem install mcp_ui_server
```

## بناء أول مكون MCP-UI

لنبدأ بمثال بسيط يوضح المفاهيم الأساسية لـ MCP-UI.

### مثال TypeScript: تحية تفاعلية

#### تنفيذ جانب الخادم

```typescript
import { createUIResource } from '@mcp-ui/server';

// تحية HTML بسيطة
const createGreetingResource = (name: string) => {
  return createUIResource({
    uri: `ui://greeting/${Date.now()}`,
    content: {
      type: 'rawHtml',
      htmlString: `
        <div style="padding: 20px; border: 2px solid #007acc; border-radius: 8px; background: #f0f8ff;">
          <h2 style="color: #007acc; margin: 0 0 10px 0;">مرحباً، ${name}!</h2>
          <p style="margin: 0; color: #333;">أهلاً بك في دليل MCP-UI.</p>
          <button onclick="window.parent.postMessage({type: 'tool', payload: {toolName: 'nextStep', params: {action: 'continue'}}}, '*')" 
                  style="margin-top: 15px; padding: 8px 16px; background: #007acc; color: white; border: none; border-radius: 4px; cursor: pointer;">
            متابعة الدليل
          </button>
        </div>
      `
    },
    encoding: 'text'
  });
};

// الاستخدام في أداة خادم MCP
export const greetingTool = {
  name: 'create_greeting',
  description: 'إنشاء واجهة تحية تفاعلية',
  inputSchema: {
    type: 'object',
    properties: {
      name: { type: 'string', description: 'الاسم للتحية' }
    },
    required: ['name']
  },
  handler: async (args: { name: string }) => {
    const resource = createGreetingResource(args.name);
    return {
      content: [
        {
          type: 'resource',
          resource: resource
        }
      ]
    };
  }
};
```

#### عرض جانب العميل

```typescript
import React from 'react';
import { UIResourceRenderer } from '@mcp-ui/client';

interface MCPUIAppProps {
  mcpResource: any;
}

function MCPUIApp({ mcpResource }: MCPUIAppProps) {
  const handleUIAction = (result: any) => {
    console.log('تم استلام إجراء واجهة المستخدم:', result);
    
    // التعامل مع أنواع الإجراءات المختلفة
    switch (result.payload?.toolName) {
      case 'nextStep':
        console.log('المستخدم يريد متابعة الدليل');
        // تشغيل الخطوة التالية في التطبيق
        break;
      default:
        console.log('إجراء غير معروف:', result);
    }
  };

  if (
    mcpResource.type === 'resource' &&
    mcpResource.resource.uri?.startsWith('ui://')
  ) {
    return (
      <UIResourceRenderer
        resource={mcpResource.resource}
        onUIAction={handleUIAction}
      />
    );
  }

  return <p>نوع مورد غير مدعوم</p>;
}

export default MCPUIApp;
```

### مثال Ruby: لوحة معلومات بسيطة

```ruby
require 'mcp_ui_server'

class DashboardServer
  def create_dashboard_resource(data)
    McpUiServer.create_ui_resource(
      uri: "ui://dashboard/#{Time.now.to_i}",
      content: {
        type: :raw_html,
        htmlString: build_dashboard_html(data)
      },
      encoding: :text
    )
  end

  private

  def build_dashboard_html(data)
    <<~HTML
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h1 style="color: #2c3e50; text-align: center;">لوحة معلومات النظام</h1>
        
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 20px 0;">
          #{data.map { |item| create_card_html(item) }.join}
        </div>
        
        <button onclick="refreshDashboard()" 
                style="width: 100%; padding: 12px; background: #3498db; color: white; border: none; border-radius: 6px; font-size: 16px; cursor: pointer;">
          تحديث البيانات
        </button>
        
        <script>
          function refreshDashboard() {
            window.parent.postMessage({
              type: 'tool',
              payload: {
                toolName: 'refresh_dashboard',
                params: { timestamp: new Date().toISOString() }
              }
            }, '*');
          }
        </script>
      </div>
    HTML
  end

  def create_card_html(item)
    <<~HTML
      <div style="background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); border-left: 4px solid #3498db;">
        <h3 style="margin: 0 0 10px 0; color: #2c3e50;">#{item[:title]}</h3>
        <p style="margin: 0; font-size: 24px; font-weight: bold; color: #27ae60;">#{item[:value]}</p>
        <small style="color: #7f8c8d;">#{item[:description]}</small>
      </div>
    HTML
  end
end

# مثال الاستخدام
dashboard_data = [
  { title: 'المستخدمون النشطون', value: '1,234', description: 'متصلون حالياً' },
  { title: 'الإيرادات', value: '$45,678', description: 'هذا الشهر' },
  { title: 'الطلبات', value: '892', description: 'في انتظار المعالجة' }
]

server = DashboardServer.new
resource = server.create_dashboard_resource(dashboard_data)
```

## الميزات المتقدمة: مكونات DOM البعيدة

DOM البعيد هو أقوى ميزة في MCP-UI، مما يسمح بإنشاء مكونات ديناميكية ومدركة للإطار يمكنها التفاعل بسلاسة مع التطبيق المضيف.

### مثال React DOM البعيد

```typescript
import { createUIResource } from '@mcp-ui/server';

const createInteractiveFormResource = () => {
  return createUIResource({
    uri: 'ui://forms/user-registration',
    content: {
      type: 'remoteDom',
      script: `
        // إنشاء حاوية النموذج
        const form = document.createElement('div');
        form.style.cssText = 'max-width: 400px; margin: 0 auto; padding: 20px; background: #f8f9fa; border-radius: 8px;';
        
        // عنوان النموذج
        const title = document.createElement('h2');
        title.textContent = 'تسجيل المستخدم';
        title.style.cssText = 'color: #495057; margin-bottom: 20px; text-align: center;';
        form.appendChild(title);
        
        // إدخال الاسم
        const nameGroup = createInputGroup('الاسم', 'text', 'name');
        form.appendChild(nameGroup);
        
        // إدخال البريد الإلكتروني
        const emailGroup = createInputGroup('البريد الإلكتروني', 'email', 'email');
        form.appendChild(emailGroup);
        
        // اختيار الدور
        const roleGroup = createSelectGroup('الدور', 'role', [
          { value: 'user', label: 'مستخدم' },
          { value: 'admin', label: 'مدير' },
          { value: 'moderator', label: 'مشرف' }
        ]);
        form.appendChild(roleGroup);
        
        // زر الإرسال
        const submitBtn = document.createElement('button');
        submitBtn.textContent = 'تسجيل المستخدم';
        submitBtn.style.cssText = 'width: 100%; padding: 12px; background: #007bff; color: white; border: none; border-radius: 4px; font-size: 16px; cursor: pointer; margin-top: 20px;';
        
        submitBtn.addEventListener('click', (e) => {
          e.preventDefault();
          
          const formData = {
            name: form.querySelector('[name="name"]').value,
            email: form.querySelector('[name="email"]').value,
            role: form.querySelector('[name="role"]').value
          };
          
          // التحقق من صحة النموذج
          if (!formData.name || !formData.email) {
            alert('يرجى ملء جميع الحقول المطلوبة');
            return;
          }
          
          // إرسال البيانات إلى الوالد
          window.parent.postMessage({
            type: 'tool',
            payload: {
              toolName: 'register_user',
              params: formData
            }
          }, '*');
        });
        
        form.appendChild(submitBtn);
        
        // الوظائف المساعدة
        function createInputGroup(label, type, name) {
          const group = document.createElement('div');
          group.style.cssText = 'margin-bottom: 15px;';
          
          const labelEl = document.createElement('label');
          labelEl.textContent = label;
          labelEl.style.cssText = 'display: block; margin-bottom: 5px; font-weight: 500; color: #495057;';
          
          const input = document.createElement('input');
          input.type = type;
          input.name = name;
          input.style.cssText = 'width: 100%; padding: 8px 12px; border: 1px solid #ced4da; border-radius: 4px; font-size: 14px;';
          input.required = true;
          
          group.appendChild(labelEl);
          group.appendChild(input);
          return group;
        }
        
        function createSelectGroup(label, name, options) {
          const group = document.createElement('div');
          group.style.cssText = 'margin-bottom: 15px;';
          
          const labelEl = document.createElement('label');
          labelEl.textContent = label;
          labelEl.style.cssText = 'display: block; margin-bottom: 5px; font-weight: 500; color: #495057;';
          
          const select = document.createElement('select');
          select.name = name;
          select.style.cssText = 'width: 100%; padding: 8px 12px; border: 1px solid #ced4da; border-radius: 4px; font-size: 14px;';
          
          options.forEach(option => {
            const optionEl = document.createElement('option');
            optionEl.value = option.value;
            optionEl.textContent = option.label;
            select.appendChild(optionEl);
          });
          
          group.appendChild(labelEl);
          group.appendChild(select);
          return group;
        }
        
        // إضافة النموذج إلى الجذر
        root.appendChild(form);
      `,
      framework: 'react'
    },
    encoding: 'text'
  });
};
```

## اختبار تنفيذ MCP-UI

### استخدام مفتش واجهة المستخدم

يوفر MCP-UI مفتش واجهة مستخدم مدمج لاختبار تنفيذاتك محلياً:

```bash
# تثبيت مفتش واجهة المستخدم
npm install -g @mcp-ui/ui-inspector

# تشغيل المفتش
ui-inspector --server your-mcp-server-config.json
```

### إعداد الاختبار المحلي

إنشاء بيئة اختبار للتحقق من مكونات MCP-UI:

```typescript
// test-mcp-ui.ts
import { createUIResource } from '@mcp-ui/server';
import { UIResourceRenderer } from '@mcp-ui/client';

// اختبار موارد واجهة المستخدم
const testResource = createUIResource({
  uri: 'ui://test/component',
  content: {
    type: 'rawHtml',
    htmlString: '<div>مكون الاختبار</div>'
  },
  encoding: 'text'
});

console.log('المورد المُنشأ:', JSON.stringify(testResource, null, 2));
```

### اختبار التكامل

```bash
# الاختبار مع خادم MCP حقيقي
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{"method": "tools/call", "params": {"name": "create_greeting", "arguments": {"name": "World"}}}'
```

## أفضل الممارسات والأمان

### اعتبارات الأمان

1. **تطهير المدخلات**: قم دائماً بتطهير مدخلات المستخدم قبل العرض في HTML
2. **سياسة أمان المحتوى**: تنفيذ رؤوس CSP المناسبة لمحتوى iframe
3. **قيود الصندوق المعزول**: الاستفادة من عزل iframe للمحتوى غير الموثوق
4. **التحقق من الأحداث**: التحقق من جميع أحداث إجراءات واجهة المستخدم قبل المعالجة

### تحسين الأداء

1. **تخزين الموارد مؤقتاً**: تخزين موارد واجهة المستخدم المستخدمة بكثرة مؤقتاً
2. **التحميل الكسول**: تحميل مكونات واجهة المستخدم فقط عند الحاجة
3. **حجم الحزمة**: الحفاظ على حزم JavaScript صغيرة للتحميل الأسرع
4. **إزالة الارتداد من الأحداث**: إزالة الارتداد من أحداث واجهة المستخدم المتكررة لمنع الرسائل المزعجة

### تنظيم الكود

```typescript
// تنظيم موارد واجهة المستخدم
export class UIResourceFactory {
  static createDashboard(data: DashboardData): UIResource {
    // التنفيذ
  }
  
  static createForm(schema: FormSchema): UIResource {
    // التنفيذ
  }
  
  static createChart(chartData: ChartData): UIResource {
    // التنفيذ
  }
}

// استخدام اصطلاحات تسمية متسقة
const UI_NAMESPACES = {
  DASHBOARD: 'ui://dashboard',
  FORMS: 'ui://forms',
  CHARTS: 'ui://charts'
} as const;
```

## مضيفو MCP المدعومون

MCP-UI متوافق مع عدة مضيفين لـ MCP، كل منهم يوفر مستويات متفاوتة من دعم الميزات:

| المضيف | العرض | إجراءات واجهة المستخدم | ملاحظات |
|------|-----------|------------|-------|
| **Postman** | ✅ | ⚠️ | عرض كامل، دعم جزئي للإجراءات |
| **Goose** | ✅ | ⚠️ | تكامل جيد، بعض قيود الإجراءات |
| **Smithery** | ✅ | ❌ | العرض فقط، لا توجد ميزات تفاعلية |
| **MCPJam** | ✅ | ❌ | بيئة ساحة اللعب |
| **VSCode** | 🔄 | 🔄 | قريباً |

## استكشاف الأخطاء وإصلاحها

### عدم عرض واجهة المستخدم

```typescript
// التحقق من تنسيق المورد
const resource = createUIResource({
  uri: 'ui://test/1', // يجب أن يبدأ بـ 'ui://'
  content: {
    type: 'rawHtml', // نوع المحتوى الصحيح
    htmlString: '<div>المحتوى</div>' // HTML صالح
  },
  encoding: 'text' // الترميز الصحيح
});
```

### الإجراءات لا تعمل

```javascript
// التأكد من تنسيق الحدث المناسب
window.parent.postMessage({
  type: 'tool', // يجب أن يكون 'tool'
  payload: {
    toolName: 'your_tool_name', // اسم أداة صالح
    params: { /* معاملات صالحة */ }
  }
}, '*');
```

### مشاكل التصميم

```html
<!-- استخدام الأنماط المضمنة للتوافق الأفضل -->
<div style="padding: 20px; background: #f0f0f0;">
  المحتوى مع الأنماط المضمنة
</div>
```

## الخلاصة

يمثل MCP-UI تقدماً كبيراً في واجهات وكلاء الذكاء الاصطناعي، مما يتيح تجارب غنية وتفاعلية تتجاوز بكثير التفاعلات التقليدية القائمة على النص. من خلال اتباع هذا الدليل، تعلمت كيفية:

- إعداد MCP-UI في بيئتي TypeScript و Ruby
- إنشاء مكونات واجهة مستخدم تفاعلية باستخدام أنواع محتوى مختلفة
- تنفيذ ميزات متقدمة مثل مكونات DOM البعيدة
- التعامل مع إجراءات وأحداث واجهة المستخدم بشكل صحيح
- اتباع أفضل الممارسات الأمنية وتقنيات التحسين

مستقبل تفاعلات وكلاء الذكاء الاصطناعي يكمن في واجهات المستخدم السلسة والبديهية، ويوفر MCP-UI الأساس لبناء تجارب الجيل التالي هذه. سواء كنت تنشئ لوحات معلومات بسيطة أو تطبيقات تفاعلية معقدة، يوفر MCP-UI المرونة والقوة اللازمة لتحقيق رؤيتك.

## موارد إضافية

- **الوثائق الرسمية**: [mcpui.dev](https://mcpui.dev)
- **مستودع GitHub**: [github.com/idosal/mcp-ui](https://github.com/idosal/mcp-ui)
- **أمثلة مباشرة**: جرب خوادم العرض التوضيحي المستضافة
- **المجتمع**: انضم إلى مجتمع MCP-UI للدعم والمناقشات

ابدأ في بناء مكونات MCP-UI الخاصة بك اليوم وحوّل كيفية تفاعل المستخدمين مع وكلاء الذكاء الاصطناعي!
