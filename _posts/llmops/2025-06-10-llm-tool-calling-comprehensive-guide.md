---
title: "LLM Tool Calling 완전 정복 - Claude & GPT-4 실전 가이드"
date: 2025-06-10
categories: 
  - llmops
  - AI Engineering
tags: 
  - Tool Calling
  - Claude
  - GPT-4
  - Function Calling
  - Cursor
  - Computer Use
  - Pydantic
  - LangChain
author_profile: true
toc: true
toc_label: 목차
---

AI 모델이 단순한 텍스트 생성을 넘어 실제 도구를 사용하여 복잡한 작업을 수행할 수 있게 하는 Tool Calling은 현대 AI 시스템의 핵심 기능입니다. Claude와 GPT-4의 Tool Calling 활용법부터 IDE 통합, 데스크톱 자동화까지 실전에서 바로 적용할 수 있는 완전한 가이드를 제공합니다.

## 툴 콜링 기본 골격

모든 Tool Calling 시스템의 기본 구조는 JSON Schema를 통한 도구 정의로 시작됩니다:

```json
"tools": [{
  "name": "get_weather",
  "description": "Get current weather in a city",
  "input_schema": {
    "type": "object",
    "properties": {
      "location": {"type": "string"},
      "unit": {"type": "string", "enum": ["celsius","fahrenheit"]}
    },
    "required": ["location"]
  }
}]
```

- `name`·`description`·`input_schema` 세 필드는 Anthropic Claude, OpenAI GPT-4 모두 동일하게 요구됩니다. ([docs.anthropic.com][1])
- `input_schema`가 엄격할수록 모델이 매개변수를 잘 맞춥니다. ([cookbook.openai.com][4])

## Claude 단일 툴 예시 – **`get_weather`**

Claude의 Tool Calling은 직관적인 흐름으로 작동합니다:

### 1. 요청

```json
{"role":"user","content":"샌프란시스코 날씨 알려줘"}
```

### 2. 모델 응답 (`stop_reason:"tool_use"`)

```json
{
  "type":"tool_use",
  "name":"get_weather",
  "input":{"location":"San Francisco, CA","unit":"celsius"}
}
```

### 3. 클라이언트 실행 → `"15 degrees"`를 얻음.

### 4. `tool_result`로 반환 후 Claude가 최종 자연어 답을 작성. ([docs.anthropic.com][1])

이 단순해 보이는 4단계가 AI와 실제 시스템 간의 완전한 상호작용을 가능하게 합니다.

## Claude 연속 툴 예시 – **`get_location` → `get_weather`**

사용자가 "**지금 있는 곳 날씨 알려줘**"처럼 불완전한 질문을 하면 Claude가 먼저 `get_location`을 호출하여 IP 기반 위치를 얻고, 이어서 `get_weather`를 호출하는 2-스텝 체인을 자동으로 구성합니다. ([docs.anthropic.com][1])

### 연속 툴 호출의 장점

- **자동 컨텍스트 수집**: 부족한 정보를 스스로 찾아서 보완
- **단계별 추론**: 복잡한 작업을 논리적 순서로 분해
- **오류 복구**: 중간 단계 실패 시 대안 경로 탐색

## OpenAI Function Calling 비교

GPT-4o 역시 `tools` 파라미터에 함수 스펙을 넘기면 `finish_reason:"tool_calls"`와 함께 `tool_calls` 배열을 반환합니다. 차이는 **함수 선택 강제(`tool_choice`)**와 **role =`"function"` 메시지**로 결과를 주고받는 점입니다. ([cookbook.openai.com][4])

### 주요 차이점 비교

| 특징 | Claude | GPT-4 |
|-----|--------|-------|
| 중단 이유 | `stop_reason:"tool_use"` | `finish_reason:"tool_calls"` |
| 결과 전달 | `tool_result` | `role:"function"` |
| 강제 실행 | 자동 판단 | `tool_choice` 옵션 |
| 멀티 툴 | 순차 실행 | 병렬 실행 가능 |

## IDE 통합 예시 – **Cursor Agent Mode + Claude 4**

Cursor의 Agent Mode는 Tool Calling의 실전 활용을 보여주는 훌륭한 예시입니다:

- **Agent Mode**는 bash·text editor 등 "모든 툴"을 활성화한 상태로 코드 수정·`pytest` 실행·웹 검색까지 알아서 수행합니다. ([docs.cursor.com][2])
- 설정에서 **"Enable auto-run mode"**를 켜고 **Command Allowlist**를 비워 두면 모델이 생성한 셸 명령이 자동 실행되지만, 최신 포럼 이슈에 따르면 여전히 수동 확인이 필요한 경우가 있어 '완전 자동'은 별도 플래그가 필요합니다. ([forum.cursor.com][3])

### Cursor가 내부적으로 사용한 툴 예시

```json
{"type":"bash_20250124","name":"bash","command":"npm test"}
```

실행 결과가 `tool_result`로 다시 Claude에 들어가면, 다음 코드를 고치거나 테스트를 반복합니다.

### Agent Mode 활용 시나리오

```text
1. 버그 리포트 분석
2. 관련 코드 파일 검색 및 읽기  
3. 테스트 케이스 실행
4. 문제점 식별 및 수정
5. 테스트 재실행으로 검증
6. 추가 최적화 제안
```

## 데스크톱 자동화 – **`computer_20250124` 툴**

Claude 4(Opus/Sonnet)용 **Computer Use** 베타는 스크린샷·마우스·키보드 제어를 포함해 "사람처럼 PC를 조작"하는 툴입니다. ([docs.anthropic.com][5])

```json
{ "type":"computer_20250124","name":"computer",
  "display_width_px":1024,"display_height_px":768 }
```

API 헤더에 `betas:["computer-use-2025-01-24"]`를 추가해야 하며, 실제 위험을 줄이려면 VM에서 실행하라는 공식 권고가 나와 있습니다. ([anthropic.com][6])

### Computer Use 활용 사례

- **웹 브라우징 자동화**: 복잡한 웹 양식 작성
- **데스크톱 앱 제어**: GUI 기반 소프트웨어 조작
- **스크린샷 기반 분석**: 시각적 요소 인식 및 상호작용
- **크로스 플랫폼 작업**: 여러 애플리케이션 간 데이터 연동

### 보안 고려사항

```yaml
Security Measures:
  - VM 격리 환경에서 실행
  - 민감한 정보 접근 제한
  - 사용자 승인 단계 포함
  - 실행 로그 모니터링
```

## 타입-안전 설계 – **Pydantic + Claude**

Pydantic으로 Python `BaseModel`을 선언한 뒤 `.model_json_schema()`를 그대로 `input_schema`에 넣으면, Claude가 반환한 `input`을 원형 객체로 바로 파싱할 수 있어 실전 서비스에서 오류를 크게 줄여 줍니다. ([murraycole.com][7])

### Pydantic 모델 정의

```python
from pydantic import BaseModel, Field
from typing import Optional, List
from enum import Enum

class TemperatureUnit(str, Enum):
    CELSIUS = "celsius"
    FAHRENHEIT = "fahrenheit"

class WeatherRequest(BaseModel):
    location: str = Field(description="도시명 또는 좌표")
    unit: TemperatureUnit = Field(default=TemperatureUnit.CELSIUS)
    include_forecast: Optional[bool] = Field(default=False, description="일기예보 포함 여부")

class WeatherResponse(BaseModel):
    location: str
    temperature: float
    unit: TemperatureUnit
    description: str
    forecast: Optional[List[dict]] = None
```

### Claude Tool 등록

```python
import json
from anthropic import Anthropic

client = Anthropic()

def register_weather_tool():
    schema = WeatherRequest.model_json_schema()
    return {
        "name": "get_weather",
        "description": "현재 날씨 정보를 조회합니다",
        "input_schema": schema
    }

# Tool 실행 함수
def execute_weather_tool(input_data: dict) -> WeatherResponse:
    # Pydantic으로 안전하게 파싱
    request = WeatherRequest(**input_data)
    
    # 실제 날씨 API 호출
    weather_data = fetch_weather_api(request.location, request.unit)
    
    return WeatherResponse(
        location=request.location,
        temperature=weather_data["temp"],
        unit=request.unit,
        description=weather_data["desc"],
        forecast=weather_data.get("forecast") if request.include_forecast else None
    )
```

### 에러 처리 및 검증

```python
from pydantic import ValidationError

def safe_tool_execution(tool_input: dict):
    try:
        # 입력 검증
        validated_input = WeatherRequest(**tool_input)
        
        # 비즈니스 로직 실행
        result = execute_weather_tool(validated_input.dict())
        
        return {"success": True, "data": result.dict()}
        
    except ValidationError as e:
        return {"success": False, "error": "입력 검증 실패", "details": e.errors()}
    
    except Exception as e:
        return {"success": False, "error": "실행 중 오류", "details": str(e)}
```

## 라이브러리 추상화 – **LangChain Tool Calling**

LangChain `ChatModel.bind_tools([...])` 메서드는 위 JSON Schema 정의를 자동으로 감싸주고, `tool.execute()` 루프를 만들어 에이전트를 간편하게 구성할 수 있습니다. ([python.langchain.com][8])

### LangChain Tools 구현

```python
from langchain.tools import BaseTool
from langchain_anthropic import ChatAnthropic
from langchain.agents import create_tool_calling_agent, AgentExecutor
from langchain_core.prompts import ChatPromptTemplate

class WeatherTool(BaseTool):
    name = "get_weather"
    description = "현재 날씨 정보를 조회합니다"
    
    def _run(self, location: str, unit: str = "celsius") -> str:
        request = WeatherRequest(location=location, unit=unit)
        result = execute_weather_tool(request.dict())
        return f"{result.location}의 현재 기온은 {result.temperature}°{result.unit.upper()}입니다."

# Agent 설정
llm = ChatAnthropic(model="claude-3-5-sonnet-20241022")
tools = [WeatherTool()]

# Tool Calling Agent 생성
prompt = ChatPromptTemplate.from_messages([
    ("system", "당신은 날씨 정보를 제공하는 도움이 되는 어시스턴트입니다."),
    ("human", "{input}"),
    ("placeholder", "{agent_scratchpad}"),
])

agent = create_tool_calling_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)

# 실행
response = agent_executor.invoke({"input": "서울 날씨 알려줘"})
```

### 고급 Agent 패턴

```python
from langchain.agents import AgentType, initialize_agent
from langchain.memory import ConversationBufferWindowMemory

class WeatherAgent:
    def __init__(self):
        self.llm = ChatAnthropic(model="claude-3-5-sonnet-20241022")
        self.tools = [WeatherTool(), LocationTool(), ForecastTool()]
        self.memory = ConversationBufferWindowMemory(
            memory_key="chat_history",
            k=5,
            return_messages=True
        )
        
        self.agent = initialize_agent(
            tools=self.tools,
            llm=self.llm,
            agent=AgentType.OPENAI_FUNCTIONS,
            memory=self.memory,
            verbose=True,
            max_iterations=3
        )
    
    def chat(self, message: str):
        return self.agent.run(message)

# 사용 예시
weather_agent = WeatherAgent()
response = weather_agent.chat("내 위치 날씨와 내일 예보도 함께 알려줘")
```

## 실전 팁 & 주의사항

### 스키마 설계 원칙

- **스키마를 구체적으로**—모호하면 모델이 잘못 추론하거나 추가 질의를 보냅니다. ([docs.anthropic.com][1])
- **필수 필드 명확화**: `required` 배열에 반드시 필요한 매개변수만 포함
- **열거형 활용**: 가능한 값이 제한적인 경우 `enum`으로 명시
- **설명 상세화**: `description` 필드에 충분한 컨텍스트 제공

### 보안 및 안전성

- **안전 가드**—Computer Use처럼 시스템을 직접 건드리는 툴은 VM·권한 제한·휴먼 승인 단계를 둡니다. ([docs.anthropic.com][5], [anthropic.com][6])
- **입력 검증**: 모든 tool input에 대한 엄격한 validation
- **권한 최소화**: 필요한 최소 권한만 부여
- **감사 로깅**: 모든 tool 실행에 대한 상세 로그 기록

### 성능 최적화

- **IDE 통합은 양방향 루프가 필수**—LLM이 명령을 생성해도, 실행-결과를 다시 `tool_result`로 넣지 않으면 다음 추론을 못 합니다. ([docs.cursor.com][2], [cookbook.openai.com][4])
- **배치 처리**: 가능한 경우 여러 작업을 한 번에 처리
- **캐싱 활용**: 반복적인 API 호출 결과 캐싱
- **타임아웃 설정**: 긴 작업에 대한 적절한 타임아웃 구성

### 개발 워크플로

```python
# 개발 단계별 체크리스트
class ToolDevelopmentChecklist:
    def __init__(self):
        self.checklist = [
            "1. 도구 목적 명확화",
            "2. 입력/출력 스키마 정의", 
            "3. Pydantic 모델 구현",
            "4. 단위 테스트 작성",
            "5. 에러 핸들링 구현",
            "6. 보안 검토",
            "7. 성능 테스트",
            "8. 문서화 완료"
        ]
    
    def validate_tool(self, tool):
        # 각 단계별 검증 로직
        pass
```

## 마무리

JSON Schema만 준비되면 어떤 모델·환경에서도 동일한 패턴을 적용할 수 있으니, 원하시는 워크플로를 복제할 때 위 예시를 그대로 참고해 보세요! Tool Calling은 AI의 가능성을 현실 세계로 확장하는 핵심 기술입니다. 적절한 설계와 보안 고려를 통해 강력하고 안전한 AI 시스템을 구축할 수 있습니다.

[1]: https://docs.anthropic.com/en/docs/build-with-claude/tool-use "Tool use with Claude - Anthropic"
[2]: https://docs.cursor.com/chat/agent "Cursor – Agent Mode"
[3]: https://forum.cursor.com/t/auto-run-in-agent-mode-allow-all-commands-feature/83933 "Auto-Run in Agent Mode - Allow all commands feature - Feature Requests - Cursor - Community Forum"
[4]: https://cookbook.openai.com/examples/how_to_call_functions_with_chat_models "How to call functions with chat models"
[5]: https://docs.anthropic.com/en/docs/agents-and-tools/computer-use "Computer use tool - Anthropic"
[6]: https://www.anthropic.com/news/3-5-models-and-computer-use "Introducing computer use, a new Claude 3.5 Sonnet, and Claude 3.5 Haiku \ Anthropic"
[7]: https://murraycole.com/posts/claude-tool-use-pydantic "Implementing Claude Tool Use with Pydantic for Structured AI Responses"
[8]: https://python.langchain.com/docs/concepts/tool_calling/ "Tool calling | ️ LangChain" 