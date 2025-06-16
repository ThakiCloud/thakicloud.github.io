---
title: "Agent Flow 완벽 가이드: 비주얼 워크플로우로 AI 에이전트 구축하기"
excerpt: "Composio와 LangGraph 기반의 Agent Flow 플랫폼을 활용해 드래그 앤 드롭으로 AI 워크플로우를 설계하고, API로 실행하는 방법을 단계별로 소개합니다."
date: 2025-06-16
categories:
  - dev
  - llmops
tags:
  - agent-flow
  - composio
  - langgraph
  - no-code
  - ai-workflow
author_profile: true
toc: true
toc_label: Agent Flow Guide
---

## 개요

[Agent Flow](https://github.com/ComposioHQ/agent-flow)는 **Composio**와 **LangGraph**를 기반으로 구축된 모듈형 AI 에이전트 플랫폼입니다. 노코드 방식의 비주얼 인터페이스를 통해 복잡한 AI 워크플로우를 드래그 앤 드롭으로 설계하고, JSON 그래프로 저장한 뒤 단일 API 호출로 실행할 수 있습니다. ReactFlow 기반 UI와 수백 개의 사전 구축된 도구 통합을 제공하여, 개발자가 빠르게 AI 자동화 솔루션을 프로토타이핑하고 확장할 수 있도록 설계되었습니다. \[GitHub Repo\]

## 1. 핵심 특징

| 기능 | 설명 |
| --- | --- |
| **Visual Workflow Builder** | ReactFlow 기반 드래그 앤 드롭 인터페이스 |
| **Core Node Types** | Input, Output, LLM, Tool, Agent 노드 제공 |
| **API-First Architecture** | JSON 그래프를 단일 API로 실행 |
| **Composio Integration** | 수백 개 도구의 자동 인증 및 통합 |
| **Agent Patterns** | 프롬프트 체이닝, 병렬화, 라우팅, 평가-최적화 루프 |

## 2. 기술 스택

- **프론트엔드**: Next.js, TypeScript, Tailwind CSS, shadcn/ui
- **워크플로우 시각화**: ReactFlow
- **에이전트 오케스트레이션**: LangGraph
- **도구 통합**: Composio SDK

## 3. 설치 및 실행

```bash
# 1) 저장소 클론
git clone https://github.com/ComposioHQ/agent-flow.git
cd agent-flow

# 2) 의존성 설치
npm install

# 3) 개발 서버 실행
npm run dev

# 4) 브라우저에서 접속
open http://localhost:3000
```

## 4. 노드 타입별 활용법

### 4.1 Input Node
워크플로우의 진입점으로, 사용자 쿼리나 외부 데이터를 받습니다.

```json
{
  "id": "input_1",
  "type": "customInput",
  "position": { "x": 100, "y": 100 },
  "data": { "label": "User Query" }
}
```

### 4.2 LLM Node
대화형 AI 모델을 통해 의사결정을 수행합니다.

```json
{
  "id": "llm_1",
  "type": "llm",
  "position": { "x": 300, "y": 100 },
  "data": {
    "model": "gpt-4",
    "prompt": "Analyze the following query and determine the best action"
  }
}
```

### 4.3 Tool Node
외부 API나 서비스를 호출합니다.

```json
{
  "id": "tool_1",
  "type": "tool",
  "position": { "x": 500, "y": 100 },
  "data": {
    "tool": "search",
    "parameters": { "query": "{{input}}" }
  }
}
```

### 4.4 Agent Node
LLM과 Tool을 결합한 복합 노드입니다.

```json
{
  "id": "agent_1",
  "type": "agent",
  "position": { "x": 300, "y": 200 },
  "data": {
    "tools": ["search", "summarize", "email"],
    "instructions": "Search for information and send a summary via email"
  }
}
```

## 5. 실전 워크플로우 예제

### 5.1 기본 검색-요약 파이프라인

```json
{
  "nodes": [
    {
      "id": "input_1",
      "type": "customInput",
      "position": { "x": 100, "y": 100 },
      "data": { "label": "Search Query" }
    },
    {
      "id": "agent_1",
      "type": "agent",
      "position": { "x": 300, "y": 100 },
      "data": {
        "tools": ["web_search", "summarize"],
        "instructions": "Search the web and provide a concise summary"
      }
    },
    {
      "id": "output_1",
      "type": "customOutput",
      "position": { "x": 500, "y": 100 },
      "data": { "label": "Summary Result" }
    }
  ],
  "edges": [
    { "source": "input_1", "target": "agent_1" },
    { "source": "agent_1", "target": "output_1" }
  ]
}
```

### 5.2 병렬 처리 워크플로우

```json
{
  "nodes": [
    { "id": "input_1", "type": "customInput", "position": { "x": 100, "y": 200 } },
    { "id": "llm_1", "type": "llm", "position": { "x": 300, "y": 100 } },
    { "id": "tool_1", "type": "tool", "position": { "x": 300, "y": 300 } },
    { "id": "output_1", "type": "customOutput", "position": { "x": 500, "y": 200 } }
  ],
  "edges": [
    { "source": "input_1", "target": "llm_1" },
    { "source": "input_1", "target": "tool_1" },
    { "source": "llm_1", "target": "output_1" },
    { "source": "tool_1", "target": "output_1" }
  ]
}
```

## 6. API 실행

워크플로우를 JSON으로 저장한 후 API 엔드포인트로 실행할 수 있습니다.

```javascript
// API 호출 예제
const response = await fetch('/api/execute-workflow', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    workflow: workflowJson,
    input: "Find the latest AI research papers"
  })
});

const result = await response.json();
console.log(result);
```

## 7. Composio 도구 통합

Agent Flow는 Composio SDK를 통해 다양한 외부 서비스와 자동으로 연동됩니다.

```javascript
// 사용 가능한 도구 예시
const availableTools = [
  'gmail',           // 이메일 발송
  'slack',           // 슬랙 메시지
  'github',          // GitHub 작업
  'google_search',   // 웹 검색
  'calendar',        // 캘린더 관리
  'notion',          // Notion 페이지 생성
  'trello',          // 트렐로 카드 생성
  // ... 수백 개의 도구
];
```

## 8. 커스텀 노드 추가

새로운 노드 타입을 추가하려면 `components/` 디렉토리에 컴포넌트를 생성합니다.

```typescript
// components/CustomNode.tsx
import { Handle, Position } from 'reactflow';

export default function CustomNode({ data }) {
  return (
    <div className="px-4 py-2 shadow-md rounded-md bg-white border-2 border-stone-400">
      <Handle type="target" position={Position.Top} />
      <div>
        <label htmlFor="text">{data.label}:</label>
        <input id="text" name="text" className="nodrag" />
      </div>
      <Handle type="source" position={Position.Bottom} />
    </div>
  );
}
```

## 9. 프로젝트 구조

```
agent-flow/
├── app/                 # Next.js 앱 라우터
│   ├── api/            # API 엔드포인트
│   └── page.tsx        # 메인 페이지
├── components/         # React 컴포넌트
│   ├── nodes/         # 커스텀 노드 타입
│   └── ui/            # shadcn/ui 컴포넌트
├── lib/               # 유틸리티 함수
└── public/            # 정적 자산
```

## 10. 고급 패턴

### 10.1 평가-최적화 루프
```json
{
  "nodes": [
    { "id": "generator", "type": "llm", "data": { "role": "content_generator" } },
    { "id": "evaluator", "type": "llm", "data": { "role": "quality_checker" } },
    { "id": "optimizer", "type": "llm", "data": { "role": "content_improver" } }
  ],
  "edges": [
    { "source": "generator", "target": "evaluator" },
    { "source": "evaluator", "target": "optimizer" },
    { "source": "optimizer", "target": "generator", "condition": "score < 8" }
  ]
}
```

### 10.2 조건부 라우팅
```json
{
  "nodes": [
    { "id": "classifier", "type": "llm", "data": { "task": "intent_classification" } },
    { "id": "support_agent", "type": "agent", "data": { "tools": ["zendesk"] } },
    { "id": "sales_agent", "type": "agent", "data": { "tools": ["crm", "email"] } }
  ],
  "edges": [
    { "source": "classifier", "target": "support_agent", "condition": "intent == 'support'" },
    { "source": "classifier", "target": "sales_agent", "condition": "intent == 'sales'" }
  ]
}
```

## 11. 결론

Agent Flow는 복잡한 AI 워크플로우를 시각적으로 설계하고 API로 실행할 수 있는 강력한 플랫폼입니다. Composio의 광범위한 도구 생태계와 LangGraph의 유연한 오케스트레이션을 결합하여, 개발자가 빠르게 AI 자동화 솔루션을 구축할 수 있도록 지원합니다. 노코드 인터페이스와 코드 확장성을 모두 제공하므로, 프로토타이핑부터 프로덕션 배포까지 전 과정을 커버할 수 있습니다.

> 프로젝트 소스코드와 최신 업데이트는 GitHub에서 확인하세요: [ComposioHQ/agent-flow](https://github.com/ComposioHQ/agent-flow) \[GitHub Repo\] 