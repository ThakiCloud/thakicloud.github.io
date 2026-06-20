---
title: "OpenAI o3/o4-mini 함수 호출 최적화 완벽 가이드"
date: 2024-05-31
categories: 
  - tutorials
tags: 
  - openai
  - function-calling
  - o3
  - o4-mini
  - prompt-engineering
author_profile: true
toc: true
toc_label: "목차"
published: false
---

## 개요

OpenAI의 최신 모델인 o3/o4-mini는 내부적으로 더 오래 사고하도록 훈련되어 함수 호출(Function Calling) 성능이 크게 향상되었습니다. 이 가이드는 이러한 모델들의 도구 호출 기능을 최대한 활용하는 방법을 단계별로 설명합니다.

## 핵심 개선사항

### 내부 추론 능력 강화

o3/o4-mini 모델은 내부적으로 연쇄적 사고(Chain of Thought, CoT)를 수행하도록 훈련되어, 도구 호출 시 더 정확한 판단을 내릴 수 있습니다.

### 주요 특징

- **네이티브 도구 사용**: 내부 추론 과정에서 자연스럽게 도구를 활용
- **향상된 정확도**: 이전 모델(o1/o3-mini) 대비 크게 개선된 함수 호출 성능
- **상태 유지**: Responses API를 통한 추론 상태 보존

## 함수 호출 최적화 전략

### 1. Developer Message를 통한 컨텍스트 설정

효과적인 함수 호출을 위해서는 명확한 역할 정의와 행동 원칙이 필요합니다.

#### Developer Message 템플릿

```txt
You are **"AI 여행 컨시어지"**.  
Your goal is to assist users in planning, booking, and managing trips using the tools provided.

──────────────────────────────────────────
🛠️  Available Tools
1. `destination_info_get`  
   - 입력: `city_name` (string)  
   - 반환: 기후, 추천 기간, 주요 명소, 현지 규정  
2. `flight_search`  
   - 입력: `origin`, `destination`, `date_range`, `passengers`  
   - 반환: 항공편 리스트(항공사·시간·가격·좌석)  
3. `flight_book`  
   - 입력: `flight_id`, `passenger_details`, `payment_token`  
   - 반환: 예약 확인 번호(PNR)  
4. `hotel_search`  
   - 입력: `destination`, `checkin`, `checkout`, `guests`, `budget`  
   - 반환: 호텔 옵션(이름·등급·가격·취소규정)  
5. `hotel_book`  
   - 입력: `hotel_id`, `guest_details`, `payment_token`  
   - 반환: 예약 확정 번호  
6. `weather_check`  
   - 입력: `city_name`, `date`  
   - 반환: 예보(최고/최저 온도·강수 확률)  

──────────────────────────────────────────
📋  기본 행동 원칙
- **툴을 우선 사용**: 항공편 / 호텔 조회·예약·취소·일정 변경 등은 항상 해당 툴로 처리한다.  
- **툴을 사용 하지 않는 경우**  
  - 일반 여행 상식("베네치아 명물은?")  
  - 개인 추천("혼자 여행 팁 알려줘")  
  > 이때는 직접 답변하되, 필요 시 `destination_info_get`으로 정보 보강 가능.  
- **툴 호출 실패 시 재시도**: 한 번 실패해도 가능한 대안(다른 날짜·예산)을 탐색해보라.  
- **현실 제약 설명**: 예산 초과·좌석 없음 등으로 예약 불가할 때는 이유를 명확히 전달하고 대안을 제안한다.  
- **미래형 약속 금지**: "다음 턴에 예약할게요"라고 말하지 말고, 지금 바로 툴을 호출하거나 불가능 사유를 설명한다.  

──────────────────────────────────────────
🔄  대표 작업 시퀀스

### (A) 새 여행 예약
1. **여행지 확인** → `destination_info_get`  
2. **항공편 검색** → `flight_search`  
3. **항공편 선택 & 예약** → `flight_book`  
4. **호텔 검색** → `hotel_search`  
5. **호텔 예약** → `hotel_book`  
6. **필요 시 날씨 확인** → `weather_check` (출발 5일 전 자동 안내)

### (B) 예약 취소
1. **예약 상태 조회** → (내부 DB 조회)  
2. **취소 정책 확인** → `destination_info_get` (필요 시)  
3. **환불 가능 여부 안내**  
4. **사용자 확인 후** → 해당 `flight_book` 또는 `hotel_book` 레코드 **취소 API** 호출

──────────────────────────────────────────
⚠️  추가 규칙
- **개인정보 보호**: 여권번호·카드번호를 노출하지 않는다.  
- **정책 우선순위**: 각 항공사·호텔의 취소·변경 정책을 모델 추론보다 우선한다.  
- **도구 환각 방지**: 정의되지 않은 툴 이름을 만들어 호출하지 않는다.  
```

### 2. 함수 정의 최적화

#### 명확한 함수 설명

```python
tools = [{
    "type": "function",
    "name": "get_weather",
    "description": "제공된 좌표의 현재 온도를 섭씨로 가져옵니다. 사용자가 특정 위치의 날씨를 묻거나 여행 계획을 위해 기상 정보가 필요할 때 사용합니다.",
    "parameters": {
        "type": "object",
        "properties": {
            "latitude": {
                "type": "number",
                "description": "위도 (-90 ~ 90)"
            },
            "longitude": {
                "type": "number", 
                "description": "경도 (-180 ~ 180)"
            }
        },
        "required": ["latitude", "longitude"],
        "additionalProperties": False
    },
    "strict": True
}]
```

#### 복잡한 함수의 예시 포함

```python
tools = [{
    "type": "function",
    "name": "search_files",
    "description": """파일 시스템에서 정규식을 사용하여 텍스트를 검색합니다.
    
특수 문자는 반드시 이스케이프해야 합니다: ( ) [ ] { } + * ? ^ $ | . \\

예시:
- 리터럴 "function(" 검색 → "function\\("
- 리터럴 "value[index]" 검색 → "value\\[index\\]"
- 리터럴 "file.txt" 검색 → "file\\.txt"

이 함수는 코드베이스에서 특정 패턴을 찾을 때만 사용하세요.""",
    "parameters": {
        "type": "object",
        "properties": {
            "pattern": {
                "type": "string",
                "description": "검색할 정규식 패턴 (특수문자 이스케이프 필수)"
            },
            "file_extension": {
                "type": "string",
                "description": "검색할 파일 확장자 (예: .py, .js)"
            }
        },
        "required": ["pattern"],
        "additionalProperties": False
    },
    "strict": True
}]
```

## Responses API 활용

### 기본 사용법

```python
from openai import OpenAI
import requests
import json

client = OpenAI()

def get_weather(latitude, longitude):
    """실제 날씨 API 호출 함수"""
    response = requests.get(
        f"https://api.open-meteo.com/v1/forecast"
        f"?latitude={latitude}&longitude={longitude}"
        f"&current=temperature_2m,wind_speed_10m"
        f"&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m"
    )
    data = response.json()
    return data['current']['temperature_2m']

# 도구 정의
tools = [{
    "type": "function",
    "name": "get_weather",
    "description": "제공된 좌표의 현재 온도를 섭씨로 가져옵니다.",
    "parameters": {
        "type": "object",
        "properties": {
            "latitude": {"type": "number"},
            "longitude": {"type": "number"}
        },
        "required": ["latitude", "longitude"],
        "additionalProperties": False
    },
    "strict": True
}]

# 초기 컨텍스트
context = [{"role": "user", "content": "오늘 파리 날씨는 어떤가요?"}]

# 첫 번째 API 호출
response = client.responses.create(
    model="o3",  # 또는 "o4-mini"
    input=context,
    tools=tools,
    store=False,
    include=["reasoning.encrypted_content"]  # 암호화된 CoT 포함
)

# 응답을 컨텍스트에 추가
context += response.output

# 도구 호출 처리
if response.output and len(response.output) > 1:
    tool_call = response.output[1]  # 구조에 따라 조정 필요
    if hasattr(tool_call, 'arguments'):
        args = json.loads(tool_call.arguments)
        result = get_weather(args["latitude"], args["longitude"])
        
        # 함수 결과를 컨텍스트에 추가
        context.append({
            "type": "function_call_output",
            "call_id": tool_call.call_id,
            "output": str(result)
        })

# 두 번째 API 호출 (이전 추론 상태 유지)
response_2 = client.responses.create(
    model="o3",
    input=context,  # 이전 CoT 및 함수 결과 포함
    tools=tools,
    store=False,
    include=["reasoning.encrypted_content"]
)

print(response_2.output_text)
# 예시 출력: 파리의 현재 온도는 약 18.8 °C입니다.
```

### 상태 유지의 장점

- **컨텍스트 연속성**: 이전 추론 과정을 기억하여 더 일관된 응답
- **효율성 향상**: 반복적인 추론 과정 생략
- **정확도 개선**: 누적된 정보를 바탕으로 한 더 나은 의사결정

## 환각 방지 전략

### 1. 명시적 지침

```python
developer_message = """
당신은 코드 분석 도우미입니다.

중요한 규칙:
- 함수를 호출하지 않고 "나중에 호출하겠습니다"라고 말하지 마세요
- 필요한 정보가 있으면 즉시 해당 도구를 호출하세요
- 정의되지 않은 도구 이름을 만들어내지 마세요
- 도구 호출이 실패하면 대안을 제시하거나 실패 이유를 설명하세요
"""
```

### 2. 엄격한 스키마 검증

```python
tools = [{
    "type": "function",
    "name": "file_operations",
    "description": "파일 생성/수정/삭제 작업을 수행합니다.",
    "parameters": {
        "type": "object",
        "properties": {
            "operation": {
                "type": "string",
                "enum": ["create", "update", "delete"],  # 허용된 값만 지정
                "description": "수행할 작업 유형"
            },
            "file_path": {
                "type": "string",
                "pattern": "^[a-zA-Z0-9_/.-]+$",  # 정규식으로 형식 제한
                "description": "대상 파일 경로"
            }
        },
        "required": ["operation", "file_path"],
        "additionalProperties": False  # 추가 속성 금지
    },
    "strict": True  # 엄격한 스키마 검증
}]
```

## 호스팅된 도구 활용

### MCP 도구 설정

```python
# MCP 도구 설정 예시
tools = [
    {
        "type": "mcp",
        "server_label": "gitmcp",
        "server_url": "https://gitmcp.io/openai/tiktoken",
        "allowed_tools": [
            "search_tiktoken_documentation", 
            "fetch_tiktoken_documentation"
        ],  # 필요한 도구만 필터링
        "require_approval": "never"
    },
    {
        "type": "function",
        "name": "custom_calculator",
        "description": "간단한 수학 계산을 수행합니다.",
        "parameters": {
            "type": "object",
            "properties": {
                "expression": {"type": "string"}
            },
            "required": ["expression"]
        }
    }
]

# 도구 사용 우선순위 설정
developer_message = """
도구 사용 우선순위:
1. 복잡한 수학/데이터 분석: MCP Python 도구 사용
2. 간단한 산술 계산: custom_calculator 사용
3. 문서 검색: MCP 문서 도구 사용

각 도구의 적절한 사용 시점을 명확히 구분하여 사용하세요.
"""
```

### 캐싱 최적화

```python
# 이전 응답 ID를 사용한 캐싱
response = client.responses.create(
    model="o3",
    input=context,
    tools=tools,
    previous_response_id="previous_response_123",  # 캐싱 활용
    store=False
)
```

## 실전 예제: 멀티 도구 워크플로우

### 전자상거래 주문 처리 시스템

```python
# 전자상거래 도구 정의
ecommerce_tools = [
    {
        "type": "function",
        "name": "check_inventory",
        "description": "상품 재고를 확인합니다.",
        "parameters": {
            "type": "object",
            "properties": {
                "product_id": {"type": "string"},
                "quantity": {"type": "integer", "minimum": 1}
            },
            "required": ["product_id", "quantity"]
        },
        "strict": True
    },
    {
        "type": "function", 
        "name": "calculate_shipping",
        "description": "배송비를 계산합니다.",
        "parameters": {
            "type": "object",
            "properties": {
                "destination": {"type": "string"},
                "weight": {"type": "number", "minimum": 0},
                "express": {"type": "boolean", "default": False}
            },
            "required": ["destination", "weight"]
        },
        "strict": True
    },
    {
        "type": "function",
        "name": "process_payment",
        "description": "결제를 처리합니다.",
        "parameters": {
            "type": "object", 
            "properties": {
                "amount": {"type": "number", "minimum": 0},
                "payment_method": {
                    "type": "string",
                    "enum": ["credit_card", "paypal", "bank_transfer"]
                }
            },
            "required": ["amount", "payment_method"]
        },
        "strict": True
    }
]

# Developer Message
ecommerce_prompt = """
You are an **"E-commerce Order Assistant"**.
Your goal is to help customers complete their purchases efficiently.

🔄 Order Processing Workflow:
1. **재고 확인** → `check_inventory`
2. **배송비 계산** → `calculate_shipping` 
3. **총액 계산** → (상품가격 + 배송비)
4. **결제 처리** → `process_payment`

📋 Rules:
- 재고가 부족하면 대안 상품을 제안하세요
- 배송비는 항상 최종 결제 전에 고객에게 알려주세요
- 결제 실패 시 다른 결제 방법을 제안하세요
- 각 단계에서 고객에게 진행 상황을 명확히 알려주세요

⚠️ Important:
- 절대 결제를 먼저 처리하지 마세요 (재고 확인 → 배송비 계산 → 결제 순서 준수)
- 개인정보(카드번호 등)는 로그에 남기지 마세요
"""
```

## 성능 최적화 팁

### 1. 함수 개수 관리

- **권장 개수**: 100개 미만의 도구, 도구당 20개 미만의 매개변수
- **중요도 순 배치**: 자주 사용되는 도구를 먼저 정의
- **그룹화**: 관련 기능을 하나의 도구로 통합 고려

### 2. 매개변수 구조 최적화

```python
# ❌ 너무 깊은 중첩 (비권장)
{
    "user": {
        "profile": {
            "personal": {
                "address": {
                    "street": "string",
                    "city": "string"
                }
            }
        }
    }
}

# ✅ 평탄한 구조 (권장)
{
    "user_street": "string",
    "user_city": "string", 
    "user_name": "string",
    "user_email": "string"
}
```

### 3. 에러 처리 및 재시도 로직

```python
def robust_function_call(client, context, tools, max_retries=3):
    """견고한 함수 호출 래퍼"""
    for attempt in range(max_retries):
        try:
            response = client.responses.create(
                model="o3",
                input=context,
                tools=tools,
                store=False,
                include=["reasoning.encrypted_content"]
            )
            return response
        except Exception as e:
            if attempt == max_retries - 1:
                raise e
            print(f"시도 {attempt + 1} 실패: {e}")
            time.sleep(2 ** attempt)  # 지수 백오프
    
    return None
```

## 주의사항 및 베스트 프랙티스

### 1. CoT 프롬프팅 지양

```python
# ❌ 불필요한 CoT 유도 (o3/o4-mini에서는 비권장)
prompt = """
단계별로 생각해보세요:
1. 먼저 문제를 분석하고
2. 필요한 도구를 선택하고  
3. 도구를 호출하고
4. 결과를 해석하세요
"""

# ✅ 직접적인 지시 (권장)
prompt = """
사용자의 요청을 처리하기 위해 적절한 도구를 사용하세요.
"""
```

### 2. 명확한 경계 설정

```python
developer_message = """
도구 사용 경계:
- 실시간 데이터가 필요한 경우: 반드시 API 도구 사용
- 일반적인 지식 질문: 내장 지식 활용 (도구 사용 안 함)
- 계산이 필요한 경우: calculator 도구 사용
- 파일 작업: file_operations 도구 사용

절대 하지 말 것:
- 존재하지 않는 도구 호출
- 도구 없이 실시간 데이터 제공
- 미래 시점의 도구 호출 약속
"""
```

## 문제 해결 가이드

### 자주 발생하는 문제들

1. **도구 호출 환각**
   - 해결: 명시적인 도구 목록 제공 및 사용 조건 명시

2. **잘못된 매개변수 형식**
   - 해결: `strict: true` 설정 및 상세한 매개변수 설명

3. **도구 호출 순서 오류**
   - 해결: Developer Message에서 명확한 워크플로우 정의

4. **성능 저하**
   - 해결: 도구 개수 최적화 및 캐싱 활용

## 결론

OpenAI o3/o4-mini 모델의 함수 호출 기능을 최대한 활용하려면:

1. **명확한 역할 정의**: Developer Message를 통한 체계적인 지침 제공
2. **정확한 함수 설명**: 사용 조건과 예시를 포함한 상세한 설명
3. **상태 유지**: Responses API의 추론 상태 보존 기능 활용
4. **환각 방지**: 엄격한 스키마와 명시적 규칙 설정
5. **성능 최적화**: 적절한 도구 개수와 구조 관리

이러한 원칙들을 따르면 더욱 정확하고 효율적인 AI 에이전트를 구축할 수 있습니다.
