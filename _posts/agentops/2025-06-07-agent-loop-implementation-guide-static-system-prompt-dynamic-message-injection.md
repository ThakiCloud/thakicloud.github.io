---
title: "Agent Loop 구현 가이드: 정적 시스템 프롬프트와 동적 메시지 주입 패턴"
date: 2025-06-07
categories: 
  - agentops
tags: 
  - AI
  - Agent
  - LLM
  - OpenAI
  - LangGraph
  - CrewAI
  - ReAct
  - System-Prompt
author_profile: true
toc: true
toc_label: "Agent Loop 구현 가이드"
---

AI Agent 시스템의 핵심은 **정적 시스템 프롬프트(憲法) + 동적 메시지 주입** 원칙에 있습니다. 이 글에서는 OpenAI Agents SDK부터 LangGraph, CrewAI까지 다양한 프레임워크에서 이 패턴을 구현하는 방법과 운영 팁을 종합적으로 다룹니다.

## 핵심 구조 요약

### System Prompt(憲法)의 역할

**System Prompt**는 역할, 톤, 금지 규칙, 출력 포맷만 담고 세션 내내 고정됩니다. OpenAI와 Anthropic 모두 "불변 규칙은 system 역할로 두라"고 권장하고 있습니다.

### Agent Loop 패턴

`while not done:` 루프에서 다음과 같은 과정을 반복합니다:

1. **user/assistant 메시지**에 현재 목표와 툴 결과를 주입
2. LLM 호출 → **Thought/Action/Observation** 패턴으로 reasoning
3. 필요하면 툴(Function) 호출 후 Observation 추가
4. "finish" 신호가 올 때까지 반복

이 구조는 ReAct, LangChain AgentExecutor, CrewAI 등 다수 프레임워크의 기본 패턴입니다.

## OpenAI Agents SDK 실전 구현

다음은 OpenAI Agents SDK를 사용한 모범 Agent Loop 구현 예시입니다:

```python
from openai import OpenAI
import os, json

client = OpenAI()

SYSTEM_PROMPT = """
You are AcmeCorp-Research-Assistant.
Follow ALL rules:
1. Never reveal internal data.
2. Cite every source as [N].
3. Answer in Korean politely (~해요/~있어요).
"""

TOOLS = [
    {
      "type": "function",
      "function": {
        "name": "web_search",
        "description": "Run a web search and return JSON results.",
        "parameters": { "type": "object",
          "properties": { "query": { "type": "string" } },
          "required": ["query"] }
      }
    }
]

def run_agent(user_query: str) -> str:
    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user",   "content": user_query}
    ]

    for _ in range(8):                      # max 8 reasoning turns
        resp = client.chat.completions.create(
            model     = "gpt-4o-mini",
            messages  = messages,
            tools     = TOOLS,
            tool_choice = "auto"
        )
        msg = resp.choices[0].message
        messages.append(msg)

        # 1) 툴 호출 지시가 있으면 실행
        if msg.tool_calls:
            for call in msg.tool_calls:
                if call.function.name == "web_search":
                    tool_out = web_search(json.loads(call.function.arguments)["query"])
                    messages.append({
                        "role": "tool",
                        "tool_call_id": call.id,
                        "content": tool_out
                    })
        # 2) 최종 답변이면 루프 종료
        elif msg.role == "assistant":
            return msg.content

    return "죄송합니다. 답변할 수 없어요."

# demo
print(run_agent("최신 ArcFace 논문 핵심만 3줄로 요약해줘."))
```

### 코드 핵심 해설

- **SYSTEM_PROMPT**: 회사 규정, 어조, 출력 규칙(憲法)만 포함하여 루프 동안 불변 유지
- **messages** 배열에 **user → assistant → tool → assistant** 식으로 동적 대화 상태를 누적해 Agent Loop 실행
- **tool_calls**가 있으면 실제 함수를 실행해 **Observation**으로 추가 (ReAct 패턴의 Action → Observation 단계)
- 8턴 제한과 fail-safe 메시지는 무한 루프 방지용 베스트 프랙티스

## 프레임워크별 확장 방법

| 프레임워크 | 구현 포인트 | 장점 |
| --- | --- | --- |
| **LangGraph** | `StateGraph` 루트 노드에 SYSTEM_PROMPT 고정, `agent_reason → act → should_continue` 세 노드로 while-loop를 선언 | 병렬 브랜치·리듀서 내장, 토큰·시간 로깅 자동 |
| **LangChain ReAct** | `create_react_agent` + `AgentExecutor(max_iterations=8)`로 동일 루프 재현 | scratchpad에 Thought/Action/Observation 자동 기록 |
| **CrewAI / Autogen** | 각 역할별 하위 에이전트에 **로컬 system prompt**를 추가해 협업 | 멀티-에이전트, Reflection 패턴 내장 |

## CrewAI 구현 예시

CrewAI에서도 동일한 "憲法 + 동적 Task 메시지" 원칙을 적용할 수 있습니다:

```python
from crewai import Agent, Crew, Task, Process

# ➊ 헌법: 세션 내내 변하지 않는 규칙
CONSTITUTION = """
너는 2i Co., Ltd.의 AI Research Crew 멤버야.
규칙:
1) 개인 정보·내부 비밀 절대 노출 금지
2) 모든 인용은 [N] 형식으로 달 것
3) 최종 답변은 공손한 한국어(~해요/~있어요)로
"""

# ➋ 에이전트 정의 ― 모두 같은 헌법(system_template)을 사용
researcher = Agent(
    role="Research Specialist",
    goal="최신 논문·자료를 신속히 찾아 요약",
    backstory="세밀한 검증으로 정확도를 높이는 리서처",
    system_template=CONSTITUTION,   # ★ 고정 헌법
    allow_delegation=True,
    verbose=True
)

writer = Agent(
    role="Technical Writer",
    goal="연구 결과를 이해하기 쉬운 문서로 작성",
    backstory="명확한 구조와 친절한 어조로 설명하는 작가",
    system_template=CONSTITUTION,
    allow_delegation=True,
    verbose=True
)

# ➌ 동적 Task: user_query 변수·전 단계 결과가 run 시점에 주입
def build_tasks(user_query: str):
    research = Task(
        description=f"'{user_query}' 주제에 대한 최신 정보를 5개 소스 이상 조사해 요약",
        expected_output="요약본 + 출처 리스트",
        agent=researcher
    )

    write = Task(
        description="위 리서치 결과를 **개념·사례·시사점** 3단락 구조로 정리",
        expected_output="완성된 3단락 기사 (~700자)",
        agent=writer,
        context=[research]          # 연구 결과를 동적 컨텍스트로 연결
    )
    return [research, write]

def run_crew(user_query: str):
    crew = Crew(
        agents=[researcher, writer],
        tasks=build_tasks(user_query),
        process=Process.sequential,  # Research → Write 순서
        verbose=True
    )
    return crew.kickoff()
```

### CrewAI vs OpenAI SDK 비교

| 항목 | OpenAI SDK 예제 | CrewAI 예제 |
| --- | --- | --- |
| **헌법 주입 위치** | `messages=[{'role':'system',…}]` | `system_template` |
| **Loop 실행** | 수작업 `while` 루프 | `Crew.kickoff()` 내부에서 자동 |
| **에이전트 협업** | 직접 툴콜 관리 | Delegate / Ask Question 자동 주입 |
| **관측성** | 로그 직접 구현 | Verbose + Telemetry 옵션 |

## 운영 단계 Best Practice

### 1. Prompt 버전 관리

SYSTEM_PROMPT는 Git에 커밋하고 태그를 설정하며, 변경 시 A/B 테스트를 필수로 실시해야 합니다. Anthropic 연구에서도 "작은 변화가 예상 밖 결과"를 낳을 수 있다고 경고하고 있습니다.

### 2. Telemetry 설정

노드별 토큰, latency, error 메트릭을 수집해 SLA를 관리합니다. LangGraph runner는 이벤트 스트림을 노출하여 세밀한 모니터링이 가능합니다.

### 3. 비용 제어

Evaluator-Optimizer 같은 반복 패턴에는 `max_loops`와 `early_stop` 조건을 반드시 설정해야 합니다. OpenAI cookbook 예시에서도 동일한 조언을 제공하고 있습니다.

### 4. 보안 필터

툴콜 결과를 시스템 프롬프트에 넣지 말고, assistant 메시지에 observation 형태로 추가해 규칙 오염을 방지합니다. LangChain 문서에서도 "system over-write 리스크"를 주의하라고 권고하고 있습니다.

### 5. 재현 가능한 실험

학습 데이터, 툴 코드, 프롬프트를 함께 스냅샷해 버전 간 성능 차이를 추적합니다. WorkflowLLM 논문에서도 동일한 오케스트레이션의 중요성을 강조하고 있습니다.

## 실무 확장 팁

| 주제 | 실전 팁 | 근거 |
| --- | --- | --- |
| **Prompt 커스터마이징** | system_template + prompt_template + response_template 조합으로 모델별 최적 포맷을 지정 가능 | CrewAI 공식 문서 |
| **Loop 제어** | `max_iter`, `max_execution_time`을 Agent 단위로 지정해 무한 루프·과금 폭주 방지 | 프레임워크 베스트 프랙티스 |
| **툴링** | 자체 `web_search` 같은 Tool을 등록해 Action 단계에서 함수 호출 가능 | GitHub 예제 코드 |
| **관측성** | `verbose=True` & Telemetry 통합(Arize·Langfuse 등)으로 각 스텝 토큰·latency 추적 | 운영 모니터링 가이드 |
| **헌법 버전 관리** | CONSTITUTION 문자열을 Git에 두고 변경 시 A/B 테스트 | 커뮤니티 토론 참조 |

## 결론

**憲法은 단일·불변**, 나머지 컨텍스트는 **Loop 안 메시지로 동적 주입**이 엔터프라이즈 표준 패턴입니다. OpenAI SDK만으로도 구현 가능하지만, 복잡성이 증가하면 LangGraph나 CrewAI 등 **그래프/멀티-에이전트 프레임워크**로 넘어가는 것이 유지보수와 관측성 면에서 유리합니다.

위 예시를 기반으로 사내 도메인 툴만 붙이면 실무에 바로 투입할 수 있는 Agent Loop 시스템을 구축할 수 있습니다. 특히 정적 시스템 프롬프트와 동적 메시지 주입 패턴은 토큰 효율성과 일관성을 동시에 보장하는 핵심 설계 원칙입니다.
