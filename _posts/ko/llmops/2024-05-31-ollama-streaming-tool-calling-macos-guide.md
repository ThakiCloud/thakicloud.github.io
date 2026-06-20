---
title: "Ollama 스트리밍 툴 콜링 완전 가이드: macOS에서 실시간 AI 에이전트 구축하기"
date: 2024-05-31
categories: 
  - llmops
tags: 
  - Ollama
  - 툴콜링
  - 스트리밍
  - macOS
  - 로컬AI
  - 에이전트
  - Python
author_profile: true
toc: true
toc_label: "목차"
published: false
---

Ollama의 최신 업데이트로 스트리밍과 툴 콜링이 동시에 가능해졌습니다. 이제 macOS에서 완전히 로컬 환경으로 실시간 대화형 AI 에이전트를 구축할 수 있게 되었습니다. 이번 글에서는 새로운 기능들을 살펴보고, 실제 개발 환경을 구축하는 방법을 단계별로 안내하겠습니다.

## 1. 기능 업데이트 한눈에 보기

### 릴리스 일시

**2025-05-28**

### 주요 변화

1. **스트리밍 + 툴 콜링**: 오프닝 토큰부터 실시간으로 화면에 내보내면서도, 중간에 등장하는 JSON 툴 콜을 즉시 분리해 처리합니다. 더 이상 "응답 끝까지 대기 → JSON 파싱 → 함수 실행" 같은 지연이 없습니다. ([Ollama Blog](https://ollama.com/blog/streaming-tool))

2. **증분 파서**(incremental parser): 모델이 툴 전용 토큰을 갖고 있든 없든, 부분 접두사·순수 JSON 등 여러 패턴을 인식해 **실행 가능한 단일 툴 콜**로 재구성합니다. 덕분에 스트리밍과 툴 콜이 둘 다 깨지지 않습니다. ([Apidog Guide](https://apidog.com/blog/ollama-streaming-responses-and-tool-calling/))

3. **지원 모델**: Qwen 3, Devstral, Qwen 2.5 (및 coder), Llama 3.1, Llama 4 등—툴 카테고리로 배포되는 모델은 즉시 사용 가능합니다.

4. **대용량 컨텍스트** `num_ctx`: 32k까지 실험 지원—대신 메모리 사용량이 비례해 증가합니다.

---

## 2. macOS (M-시리즈 MacBook) 로컬 환경 구축

| 단계     | 명령 / 작업                           | 참고 링크                    | 비고                                        |
| ------ | --------------------------------- | ------------------------ | ----------------------------------------- |
| 설치     | `brew install ollama`             | [Homebrew Formulae](https://formulae.brew.sh/formula/ollama) | Homebrew 병 패키지, Apple Silicon/Intel 모두 지원 |
| 서비스 시작 | `brew services start ollama`      | [Chenzhang Guide](https://chenzhang.org/notes/developer/ollama-macos/) | 로그인 시 자동 실행 가능                            |
| 모델 받기  | `ollama pull llama3.1`            | —                        | 첫 실행 시 자동 pull 가능                         |
| API 사용 | `http://localhost:11434/api/chat` | [Apidog Guide](https://apidog.com/blog/ollama-streaming-responses-and-tool-calling/) | OpenAI 호환 엔드포인트 제공                        |

> **하드웨어 가속**: Apple Metal API가 기본 활성화되어 M1~M4 GPU·Neural Engine을 자동 활용합니다—추가 설정 불필요. ([Hugging Face Guide](https://huggingface.co/blog/lynn-mikami/how-to-use-ollama))

---

## 3. "로컬 툴 콜링"으로 할 수 있는 일

| 시나리오            | 요약                                                                          |
| --------------- | --------------------------------------------------------------------------- |
| **CLI/시스템 자동화** | 로컬 Python 함수 또는 shell script를 툴로 노출 → 모델이 파일 정리·Git 커밋·홈 오토메이션 같은 명령을 직접 실행 |
| **VS Code 확장**  | Ollama API를 익스텐션에서 호출해 LLM-코파일럿 구현 + 로컬 함수(예: AST 리팩터) 연동                   |
| **프라이빗 RAG**    | MacBook SSD에 있는 PDF/CSV를 Python 툴로 로드 → LLM이 즉시 검색·요약—클라우드 업로드 無            |
| **웹/모바일 프로토타입** | Next.js·Electron 앱에서 WebSocket + 툴 콜 사용 → 사용자에게 실시간 토큰 스트림 & 부분 UI 즉시 업데이트  |
| **에이전트 워크플로**   | 다중 툴(웹 스크래핑, 계산기, DB 쿼리)을 등록 → 모델이 계획-실행-피드백 루프를 전부 로컬에서 수행                 |

---

## 4. 개발자 관점 주요 이득

| 항목         | 변화 전                            | 변화 후                                   |
| ---------- | ------------------------------- | -------------------------------------- |
| **응답 지연**  | 툴 콜 포함 메시지는 전체 JSON 파싱 완료까지 블로킹 | 토큰 스트림 즉시 출력, 툴 콜만 분리되어 별도 트리거         |
| **상태 관리**  | "툴 콜인지, 일반 텍스트인지" 후처리 필요        | 파서가 **tool_calls 필드**로 반환 → 코드 단순화    |
| **모델 호환성** | 툴 콜 미학습 모델은 실패하거나 JSON 깨짐       | 파서가 JSON만 보고도 인식 → 더 많은 오픈모델 사용       |
| **맥북 리소스** | 긴 컨텍스트 사용 제약                    | `num_ctx=32000` 가능(메모리↑) → RAG 긴 문서 처리 |

---

## 5. 실무 TIP

### 1. 메모리 최적화

32k 컨텍스트는 7B 모델도 12GB+ RAM을 요구합니다. 필요 시 16k나 8k로 조정하세요.

### 2. 툴 버전 관리

Python/JS 함수 서명을 버전 컨트롤에 저장해 모델 업그레이드 시 호환성을 체크하세요.

### 3. 보안

로컬 함수가 파일 삭제·네트워크 호출을 할 수 있으므로, 인수 검증·권한 격리가 필수입니다.

### 4. 멀티-GPU/Metal

Docker에서는 Metal 패스-스루가 제한적—네이티브 실행을 권장합니다. ([Chariot Solutions](https://chariotsolutions.com/blog/post/apple-silicon-gpus-docker-and-ollama-pick-two/))

---

## 6. 앞으로 기대할 점 (관측·추정)

- **툴 마켓플레이스**: 명령어-서명만 공유해 재사용 가능한 "로컬 플러그인" 생태계가 빠르게 확대될 가능성
- **스트리밍 UI 컴포넌트**: React/SwiftUI에서 토큰 단위 스트림을 표시하는 OSS 컴포넌트가 표준화될 전망
- **Agent 프레임워크**: LangChain-JS, CrewAI 등이 `ollama://` 프로토콜을 지원하여 완전 오프라인 에이전트 구축이 쉬워질 것

---

## 실전 예제: 10분 만에 완성하는 스트리밍 AI 에이전트

아래 예시는 **"MacBook 하나만으로 실시간 대화 + 실시간 함수 호출"**을 테스트할 수 있는 **가장 실전-지향적인 최소 예제**입니다. *10분 내에 로컬에서 돌아가는 풀스택 LLM 실험 환경*이 완성됩니다.

### 1. 사전 준비

```bash
# 1) Ollama 설치 (Homebrew)
brew install ollama
brew services start ollama     # 백그라운드 서비스 등록

# 2) Python 패키지
python -m venv .venv && source .venv/bin/activate
pip install -U ollama rich
```

> **모델 다운로드**
>
> ```bash
> ollama pull qwen3     # 예시; llama3.1, devstral 등 지원 모델이면 아무거나 가능
> ```

### 2. "개발자에게 가장 유용한" 파이썬 툴: **repo_stats**

- **무엇을 하나요?**
  지정한 디렉터리(기본: 현재 Git 리포지토리)를 스캔해 **언어별 코드 라인 수** 통계를 반환합니다.
- **왜 유용한가요?**
  LLM이 내 프로젝트 규모·언어 비중을 실시간 파악→컨벤션 추천, 빌드 스크립트 생성, 리팩터링 계획 등 의사결정에 바로 활용.

### 3. 전체 코드 (`llm_agent.py`)

```python
#!/usr/bin/env python
"""
실시간 스트리밍 + 툴 콜링 데모 (MacBook 전용, Ollama + Python SDK)
"""
import os, pathlib, subprocess, json, sys
from typing import Dict
from ollama import chat, ChatResponse
from rich import print

# --------------------------- 툴 정의 --------------------------- #
def repo_stats(path: str = ".") -> Dict[str, int]:
    """
    Scan a directory recurisvely and return lines-of-code per extension.

    Args:
        path (str): directory to scan, default '.'

    Returns:
        dict: {'.py': 1234, '.js': 567, ...}
    """
    path = pathlib.Path(path).expanduser().resolve()
    if not path.is_dir():
        raise FileNotFoundError(f"{path} is not a directory")

    stats: Dict[str, int] = {}
    for p in path.rglob("*"):
        if p.is_file():
            ext = p.suffix.lower()
            try:
                lines = sum(1 for _ in p.open("r", errors="ignore"))
            except Exception:
                continue
            stats[ext] = stats.get(ext, 0) + lines
    return stats

# ------------------------ 대화 루프 --------------------------- #
SYSTEM = "You are a senior software engineer. You call tools when helpful."

def main():
    print("[bold green]🦙  LLM + Tool streaming demo (Ctrl-C to quit)[/bold green]")
    messages = [{"role": "system", "content": SYSTEM}]

    while True:
        user_input = input("\n[USER] ›  ")
        messages.append({"role": "user", "content": user_input})

        # 스트리밍 호출
        response: ChatResponse = chat(
            model="qwen3",
            messages=messages,
            tools=[repo_stats],   # 함수 객체 그대로 전달
            stream=True,
        )

        tool_results = {}
        for chunk in response:
            # ① 모델이 텍스트 생성 중이면 바로 출력
            if chunk.message.content:
                print(chunk.message.content, end="", flush=True)

            # ② tool_calls 필드가 있으면 즉시 실행
            for call in chunk.message.tool_calls or []:
                func_name = call.function.name
                args = call.function.arguments or {}
                if func_name == "repo_stats":
                    try:
                        result = repo_stats(**args)
                        # 결과를 LLM에게 피드백
                        messages.append({
                            "role": "tool",
                            "name": func_name,
                            "content": json.dumps(result)
                        })
                        tool_results[func_name] = result
                    except Exception as e:
                        messages.append({
                            "role": "tool",
                            "name": func_name,
                            "content": str(e)
                        })
        print()  # 줄바꿈
        if tool_results:
            print(f"[italic]↳ repo_stats returned:[/italic] {tool_results['repo_stats']}")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n[bold red]Session ended.[/bold red]")
```

### 실행

```bash
python llm_agent.py
```

1. **프롬프트 입력**:
   `우리 코드베이스 얼마나 큰지 알려줘. 언어별 통계를 보고 싶어.`
2. **스트림**:
   - 모델 토큰이 즉시 콘솔에 흐르고
   - 중간에 `[ToolCall] repo_stats {"path": "."}` 가 감지되면 파이썬 함수 즉시 실행
3. **결과 피드백**:
   - `repo_stats` 결과 JSON을 다시 모델에게 넘겨 다음 응답에 활용
   - 모델이 "Python 68%, JavaScript 20%, 기타 12%…" 식으로 해석해 안내

---

## 확장 아이디어

| 기능             | 간단 방법                                                            |
| -------------- | ---------------------------------------------------------------- |
| **CI 자동화**     | `run_tests()` 나 `build_docker()` 함수를 툴로 노출                       |
| **프라이빗 RAG**   | `lookup_file(path:str, query:str)` 로 PDF/MD 검색·요약                |
| **코드 변환·리팩터링** | `apply_patch(file:str, diff:str)` 로 모델이 직접 `git apply`           |
| **GUI/Web**    | FastAPI + `async for chunk in chat(stream=True)` → SSE/WebSocket |

---

## 성능·보안 팁

### 1. 메모리 조절

`OLLAMA_NUM_CTX` 환경변수(또는 `options={"num_ctx": 16000}`)로 컨텍스트 길이 튜닝.

### 2. 권한 격리

위험 명령은 wrapper 함수에서 *화이트리스트*만 허용.

### 3. 메탈 가속 확인

`ollama --version` 출력에 `metal: enabled` 표시 → GPU·Neural Engine 사용 중.

### 4. 패키지 관리

툴 함수는 **버전 관리**(git) & **타이핑** 필수—LLM이 시그니처를 신뢰.

---

## 마무리

**요약** — 이번 업데이트로 MacBook 하나만으로도 "실시간 대화 + 실시간 함수 호출"이 가능한 풀스택 LLM 실험 환경이 완성되었습니다. Homebrew 한 줄로 설치하고, Python 혹은 JavaScript에서 함수만 정의하면 곧바로 **스트리밍 대화형 에이전트**를 로컬에서 구동할 수 있습니다.

위 `llm_agent.py` 하나면 **"토큰 스트리밍 ↔ 파이썬 함수 호출 ↔ 결과 피드백"** 전체 사이클을 맥북 로컬에서 실시간으로 체험할 수 있습니다. 필요에 따라 함수만 추가해 나가면, 곧바로 개발 워크플로 전체를 LLM-에이전트화할 수 있습니다. 즐거운 실험 되세요! 🎉
