---
title: "ChatGPT와 Python으로 구축하는 MCP 서버 완전 가이드"
date: 2025-06-05
categories: 
  - AI
  - Python
  - Tutorial
tags: 
  - ChatGPT
  - MCP
  - Model Context Protocol
  - Python
  - 서버 구축
  - API 연동
author_profile: true
toc: true
toc_label: MCP 서버 구축 가이드
---

ChatGPT와 Python으로 구축한 MCP(Model Context Protocol) 서버를 연동하여 외부 도구나 데이터를 활용하는 방법을 안내해 드리겠습니다. MCP는 AI 모델과 다양한 도구 및 데이터 소스를 효과적으로 연결하는 프로토콜로, ChatGPT의 기능을 확장하는 강력한 방법입니다.

## MCP 서버 구축하기

먼저 Python을 사용하여 MCP 서버를 구축하는 방법부터 시작하겠습니다.

### MCP SDK 설치

MCP 서버를 구축하기 위해서는 먼저 필요한 라이브러리를 설치해야 합니다.

```bash
pip install "mcp[cli]"
```

### 서버 예제 코드

다음은 기본적인 MCP 서버 구현 예제입니다.

```python
# server.py
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("Demo Server")

@mcp.tool()
def add(a: int, b: int) -> int:
    """두 수를 더합니다."""
    return a + b

@mcp.resource("greeting://{name}")
def get_greeting(name: str) -> str:
    """개인화된 인사말을 반환합니다."""
    return f"안녕하세요, {name}님!"

if __name__ == "__main__":
    mcp.run()
```

이 코드는 다음과 같은 기능을 제공합니다:
- `add`: 두 수를 더하는 도구
- `greeting`: 개인화된 인사말을 반환하는 리소스

## ChatGPT에서 MCP 서버 사용하기

ChatGPT에서 MCP 서버를 사용하려면 MCP 클라이언트를 구현하여 서버에 요청을 보내야 합니다.

### MCP 클라이언트 구현

```python
import requests
import uuid
from datetime import datetime

class MCPClient:
    def __init__(self, server_url):
        self.server_url = server_url
        self.session_id = f"sess_{uuid.uuid4()}"

    def execute_operation(self, tool_name, operation, parameters):
        request = {
            "message_id": f"req_{uuid.uuid4()}",
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "source": "model",
            "destination": "tool",
            "message_type": "request",
            "content": {
                "tool_name": tool_name,
                "operation": operation,
                "parameters": parameters
            },
            "metadata": {
                "session_id": self.session_id
            }
        }
        response = requests.post(self.server_url, json=request)
        return response.json()
```

이 클라이언트는 MCP 서버에 구조화된 요청을 보내고 응답을 처리하는 역할을 합니다.

## ChatGPT와 MCP 서버 통합 과정

ChatGPT에서 MCP 서버를 활용하는 전체적인 절차는 다음과 같습니다:

### 통합 워크플로우

1. **MCP 서버 실행**: 앞서 구축한 MCP 서버를 실행합니다.

2. **클라이언트 구현**: MCP 클라이언트를 구현하여 ChatGPT와 MCP 서버 간의 통신을 담당합니다.

3. **요청 처리**: ChatGPT에서 특정 작업이 필요할 때, MCP 클라이언트를 통해 MCP 서버에 요청을 보내고 응답을 받습니다.

### 실제 사용 예시

MCP 서버가 실행되면 다음과 같이 사용할 수 있습니다:

```python
# 클라이언트 인스턴스 생성
client = MCPClient("http://localhost:8000")

# 도구 실행
result = client.execute_operation(
    tool_name="add",
    operation="execute",
    parameters={"a": 5, "b": 3}
)

print(result)  # 결과: 8
```

## 보안 고려사항

MCP 서버를 운영할 때는 다음과 같은 보안 요소를 반드시 고려해야 합니다:

### 입력 검증

사용자 입력을 철저히 검증하여 악의적인 요청을 방지합니다.

```python
def validate_input(data):
    """입력 데이터 검증"""
    if not isinstance(data, dict):
        raise ValueError("Invalid input format")
    
    # 필수 필드 확인
    required_fields = ["tool_name", "operation", "parameters"]
    for field in required_fields:
        if field not in data:
            raise ValueError(f"Missing required field: {field}")
    
    return True
```

### 도구 권한 관리

각 도구에 대한 접근 권한을 명확히 정의하여 무단 사용을 방지합니다.

```python
class AuthorizedMCP(FastMCP):
    def __init__(self, name, allowed_tools=None):
        super().__init__(name)
        self.allowed_tools = allowed_tools or []
    
    def check_permission(self, tool_name, user_id):
        """도구 사용 권한 확인"""
        if tool_name not in self.allowed_tools:
            raise PermissionError(f"Access denied for tool: {tool_name}")
        return True
```

### 세션 관리

세션 정보를 안전하게 관리하여 세션 하이재킹을 방지합니다.

```python
import hashlib
import time

class SecureSession:
    def __init__(self):
        self.sessions = {}
        
    def create_session(self, user_id):
        session_token = hashlib.sha256(
            f"{user_id}{time.time()}".encode()
        ).hexdigest()
        
        self.sessions[session_token] = {
            "user_id": user_id,
            "created_at": time.time(),
            "last_activity": time.time()
        }
        
        return session_token
    
    def validate_session(self, session_token):
        if session_token not in self.sessions:
            return False
            
        session = self.sessions[session_token]
        # 세션 만료 확인 (예: 1시간)
        if time.time() - session["last_activity"] > 3600:
            del self.sessions[session_token]
            return False
            
        # 활동 시간 업데이트
        session["last_activity"] = time.time()
        return True
```

## ChatGPT 커넥터를 통한 간편한 MCP 연결

이제는 ChatGPT에서 별도의 클라이언트 구현 없이도 커넥터 설정을 통해 MCP 서버에 직접 연결할 수 있습니다. 이 기능을 사용하면 앞서 설명한 복잡한 클라이언트 코드를 작성할 필요 없이 간편하게 MCP 서버를 활용할 수 있습니다.

![ChatGPT MCP 커넥터 설정](/assets/images/chatgpt-connector-mcp.png)

### 커넥터 설정 방법

ChatGPT의 설정에서 다음과 같이 MCP 커넥터를 구성할 수 있습니다:

1. **커넥터 생성**: ChatGPT 설정에서 "신규 커넥터" 추가
2. **서버 정보 입력**: 
   - 이름: MCP 서버의 식별 이름
   - 설명: 서버가 제공하는 기능에 대한 간단한 설명
   - MCP 서버 URL: 앞서 구축한 MCP 서버의 엔드포인트
3. **인증 설정**: OAuth 또는 기타 인증 방식 선택
4. **연결 테스트**: 설정이 완료되면 연결 상태 확인

### 커넥터의 장점

- **간편성**: 별도의 클라이언트 코드 작성 불필요
- **안정성**: ChatGPT에서 제공하는 표준화된 연결 방식
- **관리 편의성**: 설정 UI를 통한 직관적인 관리
- **보안**: OpenAI의 검증된 보안 프로토콜 적용

이 방식을 사용하면 개발자는 MCP 서버 구축에만 집중할 수 있으며, 클라이언트 측 복잡성을 크게 줄일 수 있습니다.

## 마무리

MCP(Model Context Protocol)를 활용하면 ChatGPT의 기능을 크게 확장할 수 있습니다. Python으로 구축한 MCP 서버를 통해 다양한 외부 도구와 데이터를 연동하여 더욱 강력한 AI 솔루션을 만들 수 있습니다.

특히 ChatGPT의 커넥터 기능을 활용하면 별도의 클라이언트 구현 없이도 간편하게 MCP 서버에 연결할 수 있어, 개발 과정이 훨씬 단순해집니다.

보안 요소를 철저히 고려하여 안전한 시스템을 구축하고, 사용자의 요구사항에 맞는 맞춤형 도구를 개발해 보시기 바랍니다.

