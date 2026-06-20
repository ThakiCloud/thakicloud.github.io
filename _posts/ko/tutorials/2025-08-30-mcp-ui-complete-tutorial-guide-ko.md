---
title: "MCP-UI 완전 가이드: AI 에이전트를 위한 차세대 UI 경험 구축하기"
excerpt: "MCP-UI를 사용하여 MCP(Model Context Protocol) 서버용 인터랙티브 UI 컴포넌트를 만드는 방법을 배워보세요. TypeScript와 Ruby 예제가 포함된 완전한 가이드입니다."
seo_title: "MCP-UI 튜토리얼: 인터랙티브 AI 에이전트 UI 구축 완전 가이드"
seo_description: "이 포괄적인 튜토리얼로 MCP-UI 개발을 마스터하세요. 실용적인 예제와 함께 TypeScript와 Ruby를 사용하여 AI 에이전트용 인터랙티브 UI 컴포넌트를 만드는 방법을 학습하세요."
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
toc_label: "목차"
lang: ko
permalink: /ko/tutorials/mcp-ui-complete-tutorial-guide/
canonical_url: "https://thakicloud.github.io/ko/tutorials/mcp-ui-complete-tutorial-guide/"
published: false
---

⏱️ **예상 읽기 시간**: 15분

## MCP-UI 소개

MCP(Model Context Protocol)는 AI 에이전트가 외부 시스템과 상호작용하는 방식을 혁신적으로 변화시켰습니다. 하지만 기존의 텍스트 기반 상호작용은 복잡한 데이터 시각화나 인터랙티브 워크플로우를 다룰 때 한계가 있었습니다. 바로 이런 문제를 해결하기 위해 **MCP-UI**가 등장했습니다. MCP 서버 내에서 풍부하고 인터랙티브한 사용자 인터페이스를 구현할 수 있게 해주는 혁신적인 SDK입니다.

MCP-UI를 사용하면 개발자들이 MCP 호환 클라이언트에서 직접 렌더링할 수 있는 동적 UI 컴포넌트를 생성할 수 있어, 복잡한 작업에 대해 사용자에게 직관적인 시각적 인터페이스를 제공할 수 있습니다. 데이터 대시보드, 폼 인터페이스, 인터랙티브 시각화 등 무엇을 구축하든, MCP-UI는 AI 에이전트와 사용자 친화적 인터페이스 사이의 격차를 해소합니다.

## MCP-UI란 무엇인가?

MCP-UI는 Model Context Protocol을 확장하여 풍부한 사용자 인터페이스 컴포넌트를 지원하는 오픈소스 SDK입니다. MCP 서버가 단순한 텍스트 응답뿐만 아니라 호환 클라이언트에서 렌더링할 수 있는 완전히 인터랙티브한 UI 요소를 반환할 수 있게 해줍니다.

### 주요 기능

- **다양한 콘텐츠 타입**: 원시 HTML, 외부 URL, 원격 DOM 컴포넌트 지원
- **프레임워크 유연성**: React, Web Components, 바닐라 JavaScript와 호환
- **보안 우선**: 모든 UI 콘텐츠는 최대 보안을 위해 샌드박스 iframe에서 실행
- **인터랙티브 액션**: UI 컴포넌트가 도구 호출을 트리거하고 에이전트와 상호작용 가능
- **크로스 플랫폼**: Postman, Goose, Smithery 등 여러 MCP 호스트와 호환

### 아키텍처 개요

MCP-UI는 클라이언트-서버 아키텍처를 따릅니다:

1. **서버 사이드**: MCP-UI 서버 SDK를 사용하여 UI 리소스 생성
2. **클라이언트 사이드**: MCP-UI 클라이언트 렌더러를 사용하여 UI 리소스 렌더링
3. **통신**: UI 액션은 이벤트를 통해 서버로 다시 전달

## 설치 및 설정

### 사전 요구사항

시작하기 전에 다음이 필요합니다:
- Node.js 16+ (TypeScript 개발용)
- Ruby 3.0+ (Ruby 개발용)
- MCP 개념에 대한 기본 이해
- React 또는 Web Components에 대한 친숙함

### TypeScript 설치

```bash
# npm 사용
npm install @mcp-ui/server @mcp-ui/client

# pnpm 사용
pnpm add @mcp-ui/server @mcp-ui/client

# yarn 사용
yarn add @mcp-ui/server @mcp-ui/client
```

### Ruby 설치

```bash
gem install mcp_ui_server
```

## 첫 번째 MCP-UI 컴포넌트 구축하기

MCP-UI의 핵심 개념을 보여주는 간단한 예제부터 시작해보겠습니다.

### TypeScript 예제: 인터랙티브 인사말

#### 서버 사이드 구현

```typescript
import { createUIResource } from '@mcp-ui/server';

// 간단한 HTML 인사말
const createGreetingResource = (name: string) => {
  return createUIResource({
    uri: `ui://greeting/${Date.now()}`,
    content: {
      type: 'rawHtml',
      htmlString: `
        <div style="padding: 20px; border: 2px solid #007acc; border-radius: 8px; background: #f0f8ff;">
          <h2 style="color: #007acc; margin: 0 0 10px 0;">안녕하세요, ${name}님!</h2>
          <p style="margin: 0; color: #333;">MCP-UI 튜토리얼에 오신 것을 환영합니다.</p>
          <button onclick="window.parent.postMessage({type: 'tool', payload: {toolName: 'nextStep', params: {action: 'continue'}}}, '*')" 
                  style="margin-top: 15px; padding: 8px 16px; background: #007acc; color: white; border: none; border-radius: 4px; cursor: pointer;">
            튜토리얼 계속하기
          </button>
        </div>
      `
    },
    encoding: 'text'
  });
};

// MCP 서버 도구에서 사용
export const greetingTool = {
  name: 'create_greeting',
  description: '인터랙티브 인사말 UI 생성',
  inputSchema: {
    type: 'object',
    properties: {
      name: { type: 'string', description: '인사할 이름' }
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

#### 클라이언트 사이드 렌더링

```typescript
import React from 'react';
import { UIResourceRenderer } from '@mcp-ui/client';

interface MCPUIAppProps {
  mcpResource: any;
}

function MCPUIApp({ mcpResource }: MCPUIAppProps) {
  const handleUIAction = (result: any) => {
    console.log('UI 액션 수신:', result);
    
    // 다양한 액션 타입 처리
    switch (result.payload?.toolName) {
      case 'nextStep':
        console.log('사용자가 튜토리얼을 계속하려고 합니다');
        // 애플리케이션에서 다음 단계 트리거
        break;
      default:
        console.log('알 수 없는 액션:', result);
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

  return <p>지원되지 않는 리소스 타입입니다</p>;
}

export default MCPUIApp;
```

### Ruby 예제: 간단한 대시보드

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
        <h1 style="color: #2c3e50; text-align: center;">시스템 대시보드</h1>
        
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 20px 0;">
          #{data.map { |item| create_card_html(item) }.join}
        </div>
        
        <button onclick="refreshDashboard()" 
                style="width: 100%; padding: 12px; background: #3498db; color: white; border: none; border-radius: 6px; font-size: 16px; cursor: pointer;">
          데이터 새로고침
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

# 사용 예제
dashboard_data = [
  { title: '활성 사용자', value: '1,234', description: '현재 온라인' },
  { title: '수익', value: '₩45,678,000', description: '이번 달' },
  { title: '주문', value: '892', description: '처리 대기 중' }
]

server = DashboardServer.new
resource = server.create_dashboard_resource(dashboard_data)
```

## 고급 기능: 원격 DOM 컴포넌트

원격 DOM은 MCP-UI의 가장 강력한 기능으로, 호스트 애플리케이션과 원활하게 상호작용할 수 있는 동적이고 프레임워크 인식 컴포넌트를 생성할 수 있게 해줍니다.

### React 원격 DOM 예제

```typescript
import { createUIResource } from '@mcp-ui/server';

const createInteractiveFormResource = () => {
  return createUIResource({
    uri: 'ui://forms/user-registration',
    content: {
      type: 'remoteDom',
      script: `
        // 폼 컨테이너 생성
        const form = document.createElement('div');
        form.style.cssText = 'max-width: 400px; margin: 0 auto; padding: 20px; background: #f8f9fa; border-radius: 8px;';
        
        // 폼 제목
        const title = document.createElement('h2');
        title.textContent = '사용자 등록';
        title.style.cssText = 'color: #495057; margin-bottom: 20px; text-align: center;';
        form.appendChild(title);
        
        // 이름 입력
        const nameGroup = createInputGroup('이름', 'text', 'name');
        form.appendChild(nameGroup);
        
        // 이메일 입력
        const emailGroup = createInputGroup('이메일', 'email', 'email');
        form.appendChild(emailGroup);
        
        // 역할 선택
        const roleGroup = createSelectGroup('역할', 'role', [
          { value: 'user', label: '사용자' },
          { value: 'admin', label: '관리자' },
          { value: 'moderator', label: '모더레이터' }
        ]);
        form.appendChild(roleGroup);
        
        // 제출 버튼
        const submitBtn = document.createElement('button');
        submitBtn.textContent = '사용자 등록';
        submitBtn.style.cssText = 'width: 100%; padding: 12px; background: #007bff; color: white; border: none; border-radius: 4px; font-size: 16px; cursor: pointer; margin-top: 20px;';
        
        submitBtn.addEventListener('click', (e) => {
          e.preventDefault();
          
          const formData = {
            name: form.querySelector('[name="name"]').value,
            email: form.querySelector('[name="email"]').value,
            role: form.querySelector('[name="role"]').value
          };
          
          // 폼 유효성 검사
          if (!formData.name || !formData.email) {
            alert('모든 필수 필드를 입력해주세요');
            return;
          }
          
          // 부모에게 데이터 전송
          window.parent.postMessage({
            type: 'tool',
            payload: {
              toolName: 'register_user',
              params: formData
            }
          }, '*');
        });
        
        form.appendChild(submitBtn);
        
        // 헬퍼 함수들
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
        
        // 루트에 폼 추가
        root.appendChild(form);
      `,
      framework: 'react'
    },
    encoding: 'text'
  });
};
```

## MCP-UI 구현 테스트하기

### UI 인스펙터 사용하기

MCP-UI는 로컬에서 구현을 테스트할 수 있는 내장 UI 인스펙터를 제공합니다:

```bash
# UI 인스펙터 설치
npm install -g @mcp-ui/ui-inspector

# 인스펙터 실행
ui-inspector --server your-mcp-server-config.json
```

### 로컬 테스트 설정

MCP-UI 컴포넌트를 검증하기 위한 테스트 환경을 만들어보세요:

```typescript
// test-mcp-ui.ts
import { createUIResource } from '@mcp-ui/server';
import { UIResourceRenderer } from '@mcp-ui/client';

// UI 리소스 테스트
const testResource = createUIResource({
  uri: 'ui://test/component',
  content: {
    type: 'rawHtml',
    htmlString: '<div>테스트 컴포넌트</div>'
  },
  encoding: 'text'
});

console.log('생성된 리소스:', JSON.stringify(testResource, null, 2));
```

### 통합 테스트

```bash
# 실제 MCP 서버로 테스트
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{"method": "tools/call", "params": {"name": "create_greeting", "arguments": {"name": "World"}}}'
```

## 모범 사례 및 보안

### 보안 고려사항

1. **입력 살균**: HTML에서 렌더링하기 전에 항상 사용자 입력을 살균하세요
2. **콘텐츠 보안 정책**: iframe 콘텐츠에 적절한 CSP 헤더를 구현하세요
3. **샌드박스 제한**: 신뢰할 수 없는 콘텐츠에 대해 iframe 샌드박싱을 활용하세요
4. **이벤트 검증**: 처리하기 전에 모든 UI 액션 이벤트를 검증하세요

### 성능 최적화

1. **리소스 캐싱**: 자주 사용되는 UI 리소스를 캐시하세요
2. **지연 로딩**: 필요할 때만 UI 컴포넌트를 로드하세요
3. **번들 크기**: 더 빠른 로딩을 위해 JavaScript 번들을 작게 유지하세요
4. **이벤트 디바운싱**: 스팸을 방지하기 위해 빈번한 UI 이벤트를 디바운스하세요

### 코드 구조화

```typescript
// UI 리소스 구조화
export class UIResourceFactory {
  static createDashboard(data: DashboardData): UIResource {
    // 구현
  }
  
  static createForm(schema: FormSchema): UIResource {
    // 구현
  }
  
  static createChart(chartData: ChartData): UIResource {
    // 구현
  }
}

// 일관된 명명 규칙 사용
const UI_NAMESPACES = {
  DASHBOARD: 'ui://dashboard',
  FORMS: 'ui://forms',
  CHARTS: 'ui://charts'
} as const;
```

## 지원되는 MCP 호스트

MCP-UI는 여러 MCP 호스트와 호환되며, 각각 다양한 수준의 기능 지원을 제공합니다:

| 호스트 | 렌더링 | UI 액션 | 참고사항 |
|------|-----------|------------|-------|
| **Postman** | ✅ | ⚠️ | 완전한 렌더링, 부분적 액션 지원 |
| **Goose** | ✅ | ⚠️ | 좋은 통합, 일부 액션 제한 |
| **Smithery** | ✅ | ❌ | 표시만 가능, 인터랙티브 기능 없음 |
| **MCPJam** | ✅ | ❌ | 플레이그라운드 환경 |
| **VSCode** | 🔄 | 🔄 | 곧 출시 예정 |

## 일반적인 문제 해결

### UI가 렌더링되지 않는 경우

```typescript
// 리소스 형식 확인
const resource = createUIResource({
  uri: 'ui://test/1', // 'ui://'로 시작해야 함
  content: {
    type: 'rawHtml', // 올바른 콘텐츠 타입
    htmlString: '<div>콘텐츠</div>' // 유효한 HTML
  },
  encoding: 'text' // 올바른 인코딩
});
```

### 액션이 작동하지 않는 경우

```javascript
// 적절한 이벤트 형식 확인
window.parent.postMessage({
  type: 'tool', // 'tool'이어야 함
  payload: {
    toolName: 'your_tool_name', // 유효한 도구 이름
    params: { /* 유효한 매개변수 */ }
  }
}, '*');
```

### 스타일링 문제

```html
<!-- 더 나은 호환성을 위해 인라인 스타일 사용 -->
<div style="padding: 20px; background: #f0f0f0;">
  인라인 스타일이 적용된 콘텐츠
</div>
```

## 결론

MCP-UI는 AI 에이전트 인터페이스의 중대한 발전을 나타내며, 기존의 텍스트 기반 상호작용을 훨씬 뛰어넘는 풍부하고 인터랙티브한 경험을 가능하게 합니다. 이 튜토리얼을 통해 다음을 배웠습니다:

- TypeScript와 Ruby 환경 모두에서 MCP-UI 설정하기
- 다양한 콘텐츠 타입을 사용하여 인터랙티브 UI 컴포넌트 생성하기
- 원격 DOM 컴포넌트와 같은 고급 기능 구현하기
- UI 액션과 이벤트를 적절히 처리하기
- 보안 모범 사례와 최적화 기법 따르기

AI 에이전트 상호작용의 미래는 원활하고 직관적인 사용자 인터페이스에 있으며, MCP-UI는 이러한 차세대 경험을 구축하기 위한 기반을 제공합니다. 간단한 대시보드를 만들든 복잡한 인터랙티브 애플리케이션을 만들든, MCP-UI는 여러분의 비전을 실현하는 데 필요한 유연성과 강력함을 제공합니다.

## 추가 자료

- **공식 문서**: [mcpui.dev](https://mcpui.dev)
- **GitHub 저장소**: [github.com/idosal/mcp-ui](https://github.com/idosal/mcp-ui)
- **라이브 예제**: 호스팅된 데모 서버를 체험해보세요
- **커뮤니티**: 지원과 토론을 위해 MCP-UI 커뮤니티에 참여하세요

지금 바로 자신만의 MCP-UI 컴포넌트 구축을 시작하고 사용자가 AI 에이전트와 상호작용하는 방식을 혁신해보세요!
