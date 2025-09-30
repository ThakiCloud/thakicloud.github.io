---
title: "AIO Sandbox: AI 에이전트 개발을 위한 올인원 환경 완벽 가이드"
excerpt: "브라우저 자동화, 터미널 접근, 파일 조작, VSCode 서버, MCP 통합을 하나의 컨테이너에 결합한 agent-infra/sandbox의 설정과 사용법을 완벽하게 학습하세요."
seo_title: "AIO Sandbox 튜토리얼: AI 에이전트 개발 올인원 환경 - Thaki Cloud"
seo_description: "agent-infra/sandbox 완벽 가이드 - 브라우저 자동화, VSCode 서버, Jupyter, MCP 통합이 포함된 Docker 컨테이너로 AI 에이전트 개발하기. 단계별 설정 가이드."
date: 2025-09-30
categories:
  - tutorials
tags:
  - ai-agents
  - docker
  - sandbox
  - mcp
  - browser-automation
  - vscode
  - jupyter
author_profile: true
toc: true
toc_label: "목차"
canonical_url: "https://thakicloud.github.io/ko/tutorials/agent-infra-sandbox-all-in-one-ai-development-tutorial/"
lang: ko
permalink: /ko/tutorials/agent-infra-sandbox-all-in-one-ai-development-tutorial/
---

⏱️ **예상 읽기 시간**: 12분

## 소개

AI 에이전트 개발이 빠르게 발전하는 현재, 통합되고 포괄적인 개발 환경을 갖추는 것은 생산성과 원활한 워크플로우를 위해 필수적입니다. agent-infra에서 개발한 **AIO Sandbox**(All-in-One Sandbox)는 바로 그런 환경을 제공합니다. 브라우저 자동화, 터미널 접근, 파일 조작, VSCode 서버, Jupyter 노트북, 그리고 MCP(Model Context Protocol) 통합을 하나의 Docker 컨테이너에 결합한 솔루션입니다.

이 튜토리얼에서는 기본 설치부터 인기 있는 AI 프레임워크와의 고급 통합 패턴까지, AI 에이전트 개발을 위한 AIO Sandbox 설정과 사용법을 자세히 안내해드리겠습니다.

## AIO Sandbox란 무엇인가?

AIO Sandbox는 여러 도구와 서비스를 하나의 컨테이너로 통합한 Docker 기반 개발 환경입니다:

- **🌐 브라우저 자동화**: VNC, Chrome DevTools Protocol(CDP), MCP를 통한 완전한 브라우저 제어
- **💻 개발 도구**: VSCode 서버, Jupyter 노트북, WebSocket 기반 터미널
- **📁 파일 조작**: 완전한 파일 시스템 접근 및 조작
- **🤖 MCP 통합**: 사전 구성된 Model Context Protocol 서버들
- **🚀 스마트 미리보기**: 포트 포워딩 및 웹 애플리케이션 미리보기 기능

모든 구성 요소가 동일한 파일 시스템을 공유하여 다양한 도구와 인터페이스 간의 원활한 워크플로우를 가능하게 합니다.

## 사전 요구사항

시작하기 전에 다음 사항들을 확인하세요:

- 시스템에 Docker가 설치되어 있어야 함
- Docker 명령어에 대한 기본 지식
- Python 프로그래밍 경험 (예제용)
- AI 에이전트 개념에 대한 이해

## 빠른 시작 설치

### 방법 1: 기본 Docker 실행

가장 빠른 시작 방법은 간단한 Docker 명령어를 사용하는 것입니다:

```bash
# 포트 8080에서 AIO Sandbox 실행
docker run --rm -it -p 8080:8080 ghcr.io/agent-infra/sandbox:latest
```

중국 본토 사용자의 경우 대체 레지스트리를 사용하세요:

```bash
docker run --rm -it -p 8080:8080 enterprise-public-cn-beijing.cr.volces.com/vefaas-public/all-in-one-sandbox:latest
```

### 방법 2: 특정 버전 사용

특정 버전을 사용하려면 (프로덕션 환경 권장):

```bash
# 예시: 버전 1.0.0.125 사용
docker run --rm -it -p 8080:8080 ghcr.io/agent-infra/sandbox:1.0.0.125
```

### 방법 3: Docker Compose 설정

고급 구성을 위해 `docker-compose.yaml` 파일을 생성하세요:

```yaml
version: '3.8'
services:
  sandbox:
    container_name: aio-sandbox
    image: ghcr.io/agent-infra/sandbox:latest
    volumes:
      - ./workspace:/home/gem/workspace
    security_opt:
      - seccomp:unconfined
    extra_hosts:
      - "host.docker.internal:host-gateway"
    restart: "unless-stopped"
    shm_size: "2gb"
    ports:
      - "8080:8080"
    environment:
      WORKSPACE: "/home/gem"
      TZ: "Asia/Seoul"
      HOMEPAGE: ""
      BROWSER_EXTRA_ARGS: ""
```

그 다음 실행하세요:

```bash
docker-compose up -d
```

## Sandbox 접근하기

컨테이너가 실행되면 다양한 인터페이스에 접근할 수 있습니다:

- **메인 대시보드**: http://localhost:8080
- **VSCode 서버**: http://localhost:8080/vscode
- **Jupyter 노트북**: http://localhost:8080/jupyter
- **VNC 브라우저**: http://localhost:8080/vnc
- **터미널**: http://localhost:8080/terminal

## 핵심 구성 요소 개요

### 1. 브라우저 자동화

AIO Sandbox는 브라우저와 상호작용하는 세 가지 방법을 제공합니다:

#### VNC 인터페이스
원격 데스크톱을 통한 시각적 브라우저 상호작용:
- 완전한 GUI 브라우저 경험
- 마우스 및 키보드 상호작용
- 스크린샷 기능

#### Chrome DevTools Protocol (CDP)
프로그래밍 방식의 브라우저 제어:
- 자동화된 네비게이션
- 요소 상호작용
- 성능 모니터링
- 네트워크 인터셉션

#### MCP 브라우저 도구
Model Context Protocol을 통한 고수준 브라우저 자동화:
- 일반적인 작업을 위한 단순화된 API
- AI 친화적 인터페이스
- 다른 MCP 서비스와의 통합

### 2. 개발 환경

#### VSCode 서버
브라우저에서 완전한 IDE 경험:
- 구문 강조 및 IntelliSense
- 통합 터미널
- 확장 프로그램 지원
- Git 통합

#### Jupyter 노트북
대화형 Python 개발:
- 셀 단위 코드 실행
- 풍부한 출력 표시
- 데이터 시각화
- 마크다운 문서화

### 3. 파일 시스템 조작

다음을 통한 완전한 파일 시스템 접근:
- 웹 기반 파일 관리자
- 프로그래밍 방식 접근을 위한 API 엔드포인트
- 터미널 파일 조작
- VSCode 파일 탐색기

## Python SDK 설치 및 사용법

### SDK 설치

```bash
pip install agent-sandbox
```

### 기본 SDK 사용법

주요 기능을 보여주는 포괄적인 예제입니다:

```python
import asyncio
import base64
from playwright.async_api import async_playwright
from agent_sandbox import Sandbox

async def comprehensive_sandbox_demo():
    # Sandbox 클라이언트 초기화
    client = Sandbox(base_url="http://localhost:8080")
    
    # Sandbox 컨텍스트 정보 가져오기
    context = client.sandbox.get_sandbox_context()
    home_dir = context.home_dir
    print(f"Sandbox 홈 디렉토리: {home_dir}")
    
    # 1. 파일 조작
    print("\n=== 파일 조작 ===")
    
    # 샘플 파일 생성
    sample_content = "AIO Sandbox에서 안녕하세요!\n이것은 테스트 파일입니다."
    client.file.write_file(file=f"{home_dir}/sample.txt", content=sample_content)
    
    # 파일 다시 읽기
    file_content = client.file.read_file(file=f"{home_dir}/sample.txt")
    print(f"파일 내용: {file_content.data.content}")
    
    # 디렉토리의 파일 목록 조회
    files = client.file.list_files(directory=home_dir)
    print(f"홈 디렉토리의 파일들: {[f.name for f in files.data.files]}")
    
    # 2. 셸 조작
    print("\n=== 셸 조작 ===")
    
    # 셸 명령어 실행
    result = client.shell.exec_command(command="ls -la")
    print(f"셸 출력: {result.data.output}")
    
    # Python 스크립트 생성 및 실행
    python_script = """
import datetime
import json

data = {
    'timestamp': datetime.datetime.now().isoformat(),
    'message': 'AIO Sandbox에서 생성됨',
    'numbers': [1, 2, 3, 4, 5]
}

print(json.dumps(data, indent=2, ensure_ascii=False))
"""
    
    client.file.write_file(file=f"{home_dir}/script.py", content=python_script)
    script_result = client.shell.exec_command(command=f"cd {home_dir} && python script.py")
    print(f"Python 스크립트 출력: {script_result.data.output}")
    
    # 3. Jupyter 조작
    print("\n=== Jupyter 조작 ===")
    
    # Jupyter에서 Python 코드 실행
    jupyter_code = f"""
import matplotlib.pyplot as plt
import numpy as np

# 샘플 데이터 생성
x = np.linspace(0, 10, 100)
y = np.sin(x)

# 플롯 생성
plt.figure(figsize=(10, 6))
plt.plot(x, y, 'b-', linewidth=2, label='sin(x)')
plt.xlabel('x')
plt.ylabel('y')
plt.title('AIO Sandbox에서 생성된 사인파')
plt.legend()
plt.grid(True)
plt.savefig('{home_dir}/sine_wave.png', dpi=150, bbox_inches='tight')
plt.show()

print("플롯이 성공적으로 저장되었습니다!")
"""
    
    jupyter_result = client.jupyter.execute_jupyter_code(code=jupyter_code)
    print(f"Jupyter 실행 결과: {jupyter_result.data}")
    
    # 4. 브라우저 자동화
    print("\n=== 브라우저 자동화 ===")
    
    # 브라우저 정보 가져오기
    browser_info = client.browser.get_browser_info()
    print(f"브라우저 CDP URL: {browser_info.data.cdp_url}")
    
    # Sandbox 브라우저와 함께 Playwright 사용
    async with async_playwright() as p:
        browser = await p.chromium.connect_over_cdp(browser_info.data.cdp_url)
        page = await browser.new_page()
        
        # 웹사이트로 이동
        await page.goto("https://httpbin.org/json", wait_until="networkidle")
        
        # 페이지 콘텐츠 가져오기
        content = await page.content()
        print(f"페이지 제목: {await page.title()}")
        
        # 스크린샷 촬영
        screenshot_bytes = await page.screenshot()
        screenshot_b64 = base64.b64encode(screenshot_bytes).decode('utf-8')
        
        # 스크린샷 정보 저장
        client.file.write_file(
            file=f"{home_dir}/screenshot_info.txt", 
            content=f"스크린샷 촬영 시간: {asyncio.get_event_loop().time()}\n크기: {len(screenshot_bytes)} 바이트"
        )
        
        await browser.close()
    
    print("브라우저 자동화가 성공적으로 완료되었습니다!")
    
    # 5. 고급 파일 조작
    print("\n=== 고급 파일 조작 ===")
    
    # 파일 검색
    search_result = client.file.search_files(directory=home_dir, pattern="*.py")
    print(f"발견된 Python 파일들: {[f.path for f in search_result.data.files]}")
    
    # 종합 보고서 생성
    report_content = f"""
# AIO Sandbox 데모 보고서

생성 시간: {asyncio.get_event_loop().time()}

## 생성된 파일들:
- sample.txt: 기본 텍스트 파일
- script.py: JSON 출력이 있는 Python 스크립트
- sine_wave.png: Matplotlib 시각화
- screenshot_info.txt: 브라우저 스크린샷 메타데이터

## 수행된 작업들:
1. 파일 읽기/쓰기 작업
2. 셸 명령어 실행
3. 시각화가 포함된 Jupyter 코드 실행
4. Playwright를 이용한 브라우저 자동화
5. 파일 검색 및 디렉토리 목록 조회

## Sandbox 환경:
- 홈 디렉토리: {home_dir}
- 브라우저 CDP 사용 가능: 예
- Jupyter 커널: 활성
- 셸 접근: 사용 가능

이 보고서는 AI 에이전트 개발 및 자동화 작업을 위한 
AIO Sandbox의 포괄적인 기능을 보여줍니다.
"""
    
    client.file.write_file(file=f"{home_dir}/demo_report.md", content=report_content)
    print("포괄적인 데모가 완료되었습니다! 요약은 demo_report.md를 확인하세요.")

if __name__ == "__main__":
    asyncio.run(comprehensive_sandbox_demo())
```

## 고급 통합 예제

### LangChain과의 통합

```python
from langchain.tools import BaseTool
from agent_sandbox import Sandbox
from typing import Optional

class SandboxExecutionTool(BaseTool):
    name = "sandbox_execute"
    description = """AIO Sandbox 환경에서 명령어를 실행합니다. 
    코드 실행, 파일 조작, 브라우저 자동화에 유용합니다."""
    
    def __init__(self, sandbox_url: str = "http://localhost:8080"):
        super().__init__()
        self.client = Sandbox(base_url=sandbox_url)
    
    def _run(self, command: str, operation_type: str = "shell") -> str:
        """작업 유형에 따라 sandbox에서 명령어를 실행합니다."""
        try:
            if operation_type == "shell":
                result = self.client.shell.exec_command(command=command)
                return result.data.output
            elif operation_type == "jupyter":
                result = self.client.jupyter.execute_jupyter_code(code=command)
                return str(result.data)
            elif operation_type == "file_read":
                result = self.client.file.read_file(file=command)
                return result.data.content
            else:
                return f"지원되지 않는 작업 유형: {operation_type}"
        except Exception as e:
            return f"명령어 실행 오류: {str(e)}"

# 사용 예제
sandbox_tool = SandboxExecutionTool()

# Python 코드 실행
python_result = sandbox_tool._run(
    command="print('LangChain + AIO Sandbox에서 안녕하세요!')", 
    operation_type="jupyter"
)
print(python_result)
```

### OpenAI Assistant와의 통합

```python
import json
from openai import OpenAI
from agent_sandbox import Sandbox

class OpenAISandboxIntegration:
    def __init__(self, openai_api_key: str, sandbox_url: str = "http://localhost:8080"):
        self.openai_client = OpenAI(api_key=openai_api_key)
        self.sandbox = Sandbox(base_url=sandbox_url)
    
    def run_code(self, code: str, language: str = "python") -> dict:
        """Sandbox에서 코드를 실행하고 결과를 반환합니다."""
        try:
            if language == "python":
                result = self.sandbox.jupyter.execute_jupyter_code(code=code)
                return {"success": True, "output": result.data}
            elif language == "shell":
                result = self.sandbox.shell.exec_command(command=code)
                return {"success": True, "output": result.data.output}
            else:
                return {"success": False, "error": f"지원되지 않는 언어: {language}"}
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def chat_with_code_execution(self, user_message: str) -> str:
        """OpenAI와 채팅하고 필요시 코드를 실행합니다."""
        tools = [{
            "type": "function",
            "function": {
                "name": "run_code",
                "description": "Sandbox 환경에서 Python 또는 셸 코드를 실행합니다",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "code": {"type": "string", "description": "실행할 코드"},
                        "language": {"type": "string", "enum": ["python", "shell"], "default": "python"}
                    },
                    "required": ["code"]
                }
            }
        }]
        
        response = self.openai_client.chat.completions.create(
            model="gpt-4",
            messages=[{"role": "user", "content": user_message}],
            tools=tools
        )
        
        message = response.choices[0].message
        
        if message.tool_calls:
            # 코드 실행
            tool_call = message.tool_calls[0]
            args = json.loads(tool_call.function.arguments)
            result = self.run_code(**args)
            
            if result["success"]:
                return f"코드가 성공적으로 실행되었습니다:\n{result['output']}"
            else:
                return f"코드 실행 실패: {result['error']}"
        else:
            return message.content

# 사용 예제
integration = OpenAISandboxIntegration(openai_api_key="your_api_key")
response = integration.chat_with_code_execution("10의 팩토리얼을 계산하고 간단한 플롯을 생성해주세요")
print(response)
```

## MCP (Model Context Protocol) 통합

AIO Sandbox는 AI 친화적 인터페이스를 제공하는 사전 구성된 MCP 서버들과 함께 제공됩니다:

### 사용 가능한 MCP 서버들

1. **Browser MCP**: 웹 자동화 및 스크래핑
2. **File MCP**: 파일 시스템 조작
3. **Shell MCP**: 명령어 실행
4. **Markitdown MCP**: 문서 처리
5. **Arxiv MCP**: 연구 논문 접근

### MCP 도구 사용하기

```python
from agent_sandbox import Sandbox

def demonstrate_mcp_tools():
    client = Sandbox(base_url="http://localhost:8080")
    
    # 예제: 웹 스크래핑을 위한 브라우저 MCP 사용
    # 일반적으로 MCP 클라이언트를 통해 사용됩니다
    # Sandbox는 서버 엔드포인트를 제공합니다
    
    # MCP 서버 정보 가져오기
    context = client.sandbox.get_sandbox_context()
    print(f"MCP 서버 사용 가능 위치: {context.home_dir}")
    
    # 여러 도구 결합 예제
    # 1. 브라우저를 사용하여 콘텐츠 가져오기
    browser_info = client.browser.get_browser_info()
    
    # 2. 파일 조작을 사용하여 결과 저장
    client.file.write_file(
        file=f"{context.home_dir}/mcp_demo.txt",
        content="MCP 통합 데모가 완료되었습니다"
    )
    
    # 3. 셸을 사용하여 결과 처리
    result = client.shell.exec_command(
        command=f"wc -l {context.home_dir}/mcp_demo.txt"
    )
    
    print(f"파일 처리 결과: {result.data.output}")

demonstrate_mcp_tools()
```

## 프로덕션 배포

### Kubernetes 배포

프로덕션 환경에서는 Kubernetes에 AIO Sandbox를 배포할 수 있습니다:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aio-sandbox
  namespace: ai-agents
spec:
  replicas: 2
  selector:
    matchLabels:
      app: aio-sandbox
  template:
    metadata:
      labels:
        app: aio-sandbox
    spec:
      containers:
      - name: aio-sandbox
        image: ghcr.io/agent-infra/sandbox:latest
        ports:
        - containerPort: 8080
        resources:
          limits:
            memory: "4Gi"
            cpu: "2000m"
          requests:
            memory: "2Gi"
            cpu: "1000m"
        env:
        - name: WORKSPACE
          value: "/home/gem"
        - name: TZ
          value: "Asia/Seoul"
        volumeMounts:
        - name: workspace-volume
          mountPath: /home/gem/workspace
      volumes:
      - name: workspace-volume
        persistentVolumeClaim:
          claimName: sandbox-workspace-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: aio-sandbox-service
  namespace: ai-agents
spec:
  selector:
    app: aio-sandbox
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: LoadBalancer
```

### 환경 구성

프로덕션을 위한 주요 환경 변수들:

```bash
# 보안
JWT_PUBLIC_KEY=your_jwt_public_key
PROXY_SERVER=your_proxy_server

# 워크스페이스
WORKSPACE=/home/gem
HOMEPAGE=https://your-homepage.com

# 브라우저
BROWSER_EXTRA_ARGS=--no-sandbox --disable-dev-shm-usage

# 네트워킹
DNS_OVER_HTTPS_TEMPLATES=https://cloudflare-dns.com/dns-query
WAIT_PORTS=3000,8000,9000

# 시간대
TZ=Asia/Seoul
```

## 모범 사례 및 팁

### 1. 리소스 관리

- **메모리**: 원활한 작동을 위해 최소 2GB RAM 할당
- **CPU**: 개발용으로 1-2코어 권장, 프로덕션용으로는 더 많이
- **스토리지**: 중요한 데이터를 위해 영구 볼륨 사용

### 2. 보안 고려사항

- 프로덕션에서 적절한 보안 컨텍스트로 실행
- API 접근을 위한 JWT 인증 사용
- Kubernetes에서 네트워크 정책 구현
- 컨테이너 이미지의 정기적인 보안 업데이트

### 3. 성능 최적화

- `latest` 대신 특정 버전 태그 사용
- 적절한 리소스 제한 구성
- 더 나은 I/O 성능을 위한 로컬 볼륨 사용
- 컨테이너 메트릭 모니터링

### 4. 개발 워크플로우

- 지속적인 개발을 위한 볼륨 마운트 사용
- 코드 편집을 위한 통합 VSCode 활용
- 대화형 개발 및 테스트를 위한 Jupyter 사용
- 포괄적인 워크플로우를 위한 브라우저 자동화와 파일 조작 결합

## 문제 해결

### 일반적인 문제와 해결책

#### 컨테이너가 시작되지 않음
```bash
# Docker 로그 확인
docker logs <container_id>

# 충분한 리소스 확인
docker stats

# 포트 사용 가능성 확인
netstat -tulpn | grep 8080
```

#### 브라우저 자동화 문제
```bash
# 브라우저가 실행 중인지 확인
curl http://localhost:8080/v1/browser/info

# VNC 접근 확인
# http://localhost:8080/vnc로 이동
```

#### 파일 권한 문제
```bash
# 컨테이너 내에서 소유권 수정
docker exec -it <container_id> chown -R gem:gem /home/gem
```

#### MCP 서버 연결 문제
```bash
# MCP 서버 상태 확인
docker exec -it <container_id> ps aux | grep mcp

# 필요시 MCP 서버 재시작
docker restart <container_id>
```

## 결론

AIO Sandbox는 AI 에이전트 개발을 위한 포괄적이고 통합된 환경을 제공하여 개발 워크플로우를 크게 단순화합니다. 브라우저 자동화, 개발 도구, 파일 조작, MCP 통합을 하나의 컨테이너에 결합함으로써 여러 개별 서비스를 관리하는 복잡성을 제거합니다.

주요 장점들:

- **통합 환경**: 모든 도구가 동일한 파일 시스템과 네트워크를 공유
- **쉬운 설정**: 시작하기 위한 단일 Docker 명령어
- **포괄적인 API**: 모든 기능을 위한 Python SDK 및 REST API
- **프로덕션 준비**: Kubernetes 배포 지원 및 보안 기능
- **확장 가능**: 사용자 정의 도구 개발을 위한 MCP 통합

간단한 자동화 스크립트를 구축하든 복잡한 AI 에이전트 시스템을 구축하든, AIO Sandbox는 효율적인 개발과 배포를 위해 필요한 기반을 제공합니다.

## 다음 단계

1. **실험**: 이 튜토리얼의 예제들을 시도해보세요
2. **통합**: 선호하는 AI 프레임워크와 AIO Sandbox를 연결하세요
3. **확장**: 특정 요구사항을 위한 사용자 정의 MCP 도구를 개발하세요
4. **배포**: Kubernetes 또는 Docker Compose로 프로덕션에 이동하세요
5. **기여**: 커뮤니티에 참여하고 프로젝트에 기여하세요

더 많은 정보는 [공식 저장소](https://github.com/agent-infra/sandbox)와 [문서](https://sandbox.agent-infra.com)를 방문하세요.

---

*이 튜토리얼은 AIO Sandbox에 대한 포괄적인 소개를 제공합니다. 최신 업데이트와 고급 기능은 항상 공식 문서를 참조하세요.*
