---
title: "Pepper: 실시간 이벤트 기반 아키텍처로 구축하는 프로액티브 AI 어시스턴트"
excerpt: "Gmail을 자동으로 관리하고, 중요한 이메일을 요약하며, 백그라운드에서 작업을 자율적으로 처리하는 오픈소스 개인 AI 어시스턴트 Pepper의 설치 및 활용 완벽 가이드. 이벤트 드리븐 아키텍처의 모든 것."
seo_title: "Pepper AI 어시스턴트 튜토리얼: 실시간 이벤트 기반 개인 비서 - Thaki Cloud"
seo_description: "Berkeley Sky Computing Lab에서 개발한 프로액티브 AI 어시스턴트 Pepper 설정 가이드. 설치, Gmail 연동, Feeds, Scheduler, Workers를 활용한 이벤트 드리븐 아키텍처 완벽 분석."
date: 2025-10-04
categories:
  - tutorials
tags:
  - AI-어시스턴트
  - 이벤트-드리븐-아키텍처
  - Gmail-연동
  - Agentic-시스템
  - OpenAI
  - Python
author_profile: true
toc: true
toc_label: "목차"
lang: ko
permalink: /ko/tutorials/pepper-proactive-ai-assistant-tutorial/
canonical_url: "https://thakicloud.github.io/ko/tutorials/pepper-proactive-ai-assistant-tutorial/"
---

⏱️ **예상 읽기 시간**: 12분

## 소개

**Pepper**는 AI 어시스턴트와의 상호작용 방식을 혁신하고 있습니다. 명령을 수동적으로 기다리는 전통적인 챗봇과 달리, Pepper는 **백그라운드에서 여러분을 위해 프로액티브하게 일합니다**. Gmail을 지속적으로 모니터링하고, 중요한 이메일을 요약하며, 핵심 업데이트를 표면화하고, 전문화된 워커 스웜을 통해 복잡한 작업을 자율적으로 처리합니다.

**Berkeley Sky Computing Lab**의 **Agentica 팀**이 개발한 Pepper는 반응형 요청 기반 시스템에서 실시간 이벤트 기반 아키텍처로의 근본적인 전환을 나타냅니다. 이 튜토리얼은 여러분만의 Pepper 인스턴스를 설정하고 강력한 아키텍처를 이해하는 과정을 안내합니다.

### Pepper가 특별한 이유

**전통적인 챗봇:**
- 사용자 프롬프트를 기다림
- 정적이고 반응적
- 질문을 멈추면 대화 종료

**Pepper (차세대 프로액티브 어시스턴트):**
- 백그라운드에서 지속적으로 실행
- 동적이고 프로액티브
- 적극적으로 참여하지 않아도 계속 작동
- 병렬 작업을 자율적으로 처리
- 질문하기 전에 컨텍스트 제공

### 주요 기능

✅ **Gmail 통합**: 이메일을 자동으로 모니터링하고 요약  
✅ **프로액티브 알림**: 주의가 필요한 중요 업데이트 표면화  
✅ **작업 위임**: 복잡한 작업을 전문 워커 에이전트에 할당  
✅ **이벤트 드리븐 아키텍처**: 지속적인 Sense-Think-Act 루프  
✅ **실시간 컨텍스트**: 대화 기록 및 사용자 메모리 유지  
✅ **논블로킹 설계**: 백그라운드 처리 중에도 즉시 응답

## 사전 요구사항

시작하기 전에 다음을 준비하세요:

- **운영체제**: macOS, Linux, 또는 WSL이 설치된 Windows
- **Python**: 버전 3.12 이상
- **Conda**: Anaconda 또는 Miniconda 설치
- **Gmail 계정**: 이메일 통합용
- **API 키**:
  - OpenAI API 키 (필수)
  - Composio API 키 (도구 통합에 필수)

## 설치 가이드

### 1단계: 리포지토리 클론

먼저 서브모듈과 함께 Pepper 리포지토리를 클론합니다:

```bash
git clone --recurse-submodules https://github.com/agentica-org/pepper
cd pepper
```

### 2단계: Python 환경 설정

전용 Conda 환경을 생성하고 활성화합니다:

```bash
# Python 3.12로 새 환경 생성
conda create -n pepper python=3.12 pip -y
conda activate pepper
```

### 3단계: Episodic Context Store 설치

Pepper는 실시간 데이터 백본 역할을 하는 **Episodic**이라는 컨텍스트 저장소에 의존합니다:

```bash
# 시맨틱 검색 지원과 함께 Episodic SDK 설치
cd episodic-sdk
pip install -e .[semantic]
```

### 4단계: Pepper 의존성 설치

Pepper 디렉토리로 이동하여 요구사항을 설치합니다:

```bash
cd ../pepper
pip install -r requirements.txt
```

### 5단계: Context Store 시작

Episodic 컨텍스트 저장소 서버를 실행합니다:

```bash
episodic serve --port 8000
```

**중요**: 이 프로세스를 터미널에서 계속 실행 상태로 유지하세요. 다음 단계를 위해 새 터미널 창을 여세요.

## 설정

### 1단계: 환경 변수 설정

예제 환경 파일을 복사합니다:

```bash
cd pepper
cp env_var.example.sh env_var.sh
```

### 2단계: API 키 구성

선호하는 텍스트 편집기로 `env_var.sh`를 편집합니다:

```bash
# 필수: OpenAI API 키
export OPENAI_API_KEY="sk-your-openai-api-key-here"

# 필수: Composio API 키 (Gmail 및 도구 통합용)
export COMPOSIO_API_KEY="your-composio-api-key-here"

# 선택: 추가 구성
export EPISODIC_HOST="http://localhost:8000"
```

**API 키 받기:**

1. **OpenAI API 키**:
   - [platform.openai.com](https://platform.openai.com) 방문
   - API Keys 섹션으로 이동
   - 새 시크릿 키 생성

2. **Composio API 키**:
   - [composio.dev](https://composio.dev)에서 로그인
   - 새 프로젝트 생성
   - API 키 생성

### 3단계: 환경 변수 로드

```bash
source env_var.sh
```

### 4단계: Gmail 액세스 승인

이메일 서비스 설정을 실행합니다 (최초 1회만):

```bash
python -m pepper.services.email_service
```

**예상되는 과정:**
1. 다음 메시지가 표시됩니다: `"Please authorize Gmail by visiting: [URL]"`
2. 브라우저에서 URL을 엽니다
3. Gmail 액세스 권한을 부여합니다
4. 다음 메시지를 기다립니다: `"✅ Trigger subscribed successfully."`
5. `Ctrl+C`를 눌러 프로세스를 중지합니다

## Pepper 실행

### Pepper 시작

단일 명령으로 Pepper를 시작합니다:

```bash
python -m pepper.launch_pepper
```

**최초 설정 참고사항**: 초기 실행 시 사용자 프로필을 구축하는 데 약 1분이 소요됩니다.

### 웹 UI 접속

Pepper가 실행되면 브라우저를 열고 다음 주소로 이동합니다:

```
http://localhost:5050/pepper/ui.html
```

**원격 서버 사용자**: VS Code가 자동으로 로컬 머신으로 포트 포워딩해야 합니다.

### Pepper 중지

모든 Pepper 서비스를 중지하려면:

```bash
# 터미널에서 Ctrl+C 누르기
```

## Pepper의 아키텍처 이해

Pepper의 강력함은 지속적인 **Sense-Think-Act** 루프를 중심으로 구축된 **실시간 이벤트 드리븐 아키텍처**에서 비롯됩니다.

### 핵심 컴포넌트

#### 1. **Feeds (감지)**

**목적**: 시스템의 감각 입력 레이어

Feeds는 다음을 수행하는 지능형 파이프라인입니다:
- 외부 소스(이메일, 메시지, 캘린더) 모니터링
- 노이즈 필터링
- 원시 데이터를 실행 가능한 텍스트 신호로 변환
- 높은 신호 대 노이즈 비율 유지

**예시**: 새 이메일이 도착하면 Email Feed는:
1. 키워드와 발신자 중요도 확인
2. 긴급도 수준 결정
3. 이메일을 간결한 신호로 요약:

```json
{
  "id": "evt_a1b2c3d4-e5f6-a7b8-c9d0-e1f2a3b4c5d6",
  "content": "Alice가 'Project Phoenix'에 대한 조치 요청, 내일 마감",
  "created_at": "2025-10-04T16:46:15Z"
}
```

#### 2. **Scheduler (사고)**

**목적**: 중앙 두뇌 및 오케스트레이터

Scheduler는:
- 우선순위가 지정된 FIFO 이벤트 큐 유지
- Feeds의 신호 소비
- 컨텍스트(대화 기록, 사용자 메모리)로 이벤트 강화
- 수행할 작업 결정
- 즉각적인 응답성을 위한 논블로킹 모드 작동

**핵심 혁신: 비동기 도구 호출**

전통적인 LLM API는 동기식 도구 호출을 강제합니다. 도구가 반환될 때까지 대화가 중단되어야 합니다. Pepper는 다음을 통해 이 문제를 해결합니다:
- 도구 호출을 대화 기록에 추가
- 즉시 새 이벤트 처리 계속
- 도구 결과가 도착하면 비동기적으로 처리

**이전 (동기식 - 차단됨):**
```javascript
{% raw %}
{
  "role": "assistant",
  "content": "분석을 시작합니다...",
  "tool_calls": [{"id": "tool_1", "function": "run_analysis"}]
},
// 새 사용자 입력을 받기 전에 도구 결과를 기다려야 함
{
  "role": "user",
  "content": "필터를 추가할 수 있나요?"  // 도구 결과 없이는 불가능
}
{% endraw %}
```

**이후 (비동기식 - 계속됨):**
```xml
<tool_call>
  id: tool_call_1
  function: run_analysis
</tool_call>

<user_msg>지난 분기 필터를 추가할 수 있나요?</user_msg>

<assistant_msg>네, 분석에 해당 필터를 추가하겠습니다.</assistant_msg>

<tool_result>
  id: tool_call_1
  result: {% raw %}{{ "initial_analysis_complete": true }}{% endraw %}
</tool_result>
```

#### 3. **Workers (행동)**

**목적**: 전문화된 실행 에이전트

Workers는 MCP(Model Context Protocol)를 통해 도구를 장착하여:
- 이메일 발송
- 캘린더 이벤트 관리
- 정보 검색
- 리마인더 설정
- 복잡하고 장시간 실행되는 작업 수행

**두 가지 유형의 Workers:**

**Stateful Workers**: 장시간 실행 작업용
- 상호작용 간 메모리 유지
- 이메일 스레드나 작업 목록 관리에 이상적
- Context Store에 상태 지속

**Stateless Workers**: 일회성 작업용
- 일시적이고 효율적
- 빠른 조회나 단일 사용 작업에 완벽
- 최종 답변을 반환하고 종료

#### 4. **Context Store**

**목적**: 실시간 데이터 서빙 레이어

Context Store는 Pepper의 백본으로, ML 시스템의 피처 스토어와 유사하지만 멀티 에이전트 오케스트레이션을 위해 설계되었습니다:

- **상태 관리**: 에이전트가 상태를 지속하고 공유
- **실시간 서빙**: 최신 데이터에 즉시 액세스
- **이벤트 오케스트레이션**: 업데이트가 다운스트림 작업 트리거

**핵심 API:**
- `store()`: 네임스페이스에 이벤트 저장
- `retrieve()`: 저장된 컨텍스트 쿼리
- `subscribe()`: 업데이트 리스닝

## 시스템 플로우 예시

중요한 이메일을 Pepper가 어떻게 처리하는지 살펴보겠습니다:

### 1단계: 이메일 도착 (Feed - 감지)

```python
# Gmail 웹훅 트리거
@app.on_event("new_email")
async def ingest_raw_event(data: dict):
    await context_store.store(
        context_id=data.get("id", None) or uuid.uuid(),
        data=data,
        namespace="raw.email"
    )
```

### 2단계: Feed가 신호 처리

```python
# Email Feed가 원시 이메일 구독
@subscriber.on_context_update(namespaces=["raw.email"])
async def email_feed(update: ContextUpdate):
    # 시맨틱 검색을 사용하여 관련 컨텍스트 찾기
    related_docs = await context_store.search(text=update.context.text)
    processed_signal = process_email_signal(update.context, related_docs)
    
    # 처리된 신호 발행
    await context_store.store(
        context_id="processed_" + update.context.context_id,
        data=processed_signal,
        namespace="signals.processed"
    )
```

### 3단계: Scheduler 반응 (Scheduler - 사고)

```python
# Scheduler가 신호를 우선순위 큐에 추가
@subscriber.on_context_update(namespaces=["signals.*"])
async def add_to_queue(self, update: ContextUpdate):
    priority = determine_priority(update.context.data)
    await self.priority_queue.put((priority, update))

# Scheduler가 큐를 지속적으로 처리
async def scheduler_step(self):
    events = await self.get_batch_events()
    self.state_tracker.add_events(events)
    
    messages = [
        {"role": "system", "content": SCHEDULER_SYSTEM_PROMPT},
        {"role": "user", "content": self.state_tracker.get_user_prompt()},
    ]
    
    response = await create_completion(messages, self.tools)
    self.state_tracker.add_event(response)
    
    # 백그라운드 실행을 위한 도구 호출 스케줄링
    if response.tool_calls:
        for tool_call in response.tool_calls:
            self.tool_call_engine.schedule(tool_call)
```

### 4단계: Worker가 작업 실행 (Worker - 행동)

```python
# Worker가 사용자에게 알림 발송
await worker.execute_tool("send_notification", {
    "message": "Alice의 Project Phoenix 긴급 이메일 - 내일 마감",
    "priority": "high"
})
```

## 실전 활용 사례

### 1. 이메일 관리

**시나리오**: 매일 50개 이상의 이메일을 받고 대부분이 중요하지 않음.

**Pepper의 도움**:
- Gmail을 지속적으로 모니터링
- 발신자 중요도와 키워드 기반 필터링
- 중요한 이메일만 요약
- 마감일이 있는 액션 아이템 표면화
- 프로액티브하게 알림

### 2. 회의 준비

**시나리오**: 2시간 후에 회의가 있음.

**Pepper의 도움**:
- 캘린더에서 회의 감지
- 관련 이메일 및 문서 검색
- 브리핑 문서 준비
- 주요 논의 사항 표면화
- 30분 전에 알림

### 3. 작업 위임

**시나리오**: 대규모 데이터셋을 분석해야 함.

**Pepper의 도움**:
- 작업 설명 수락
- 전문화된 Data Worker에 위임
- Worker가 백그라운드에서 분석 실행
- 다른 대화 계속 가능
- 완료되면 프로액티브 업데이트 수신

### 4. 후속 조치 관리

**시나리오**: 여러 사람의 응답을 기다리고 있음.

**Pepper의 도움**:
- 대기 중인 후속 조치 추적
- 수신 이메일 모니터링
- 응답을 원래 요청과 매칭
- 모든 응답 수신 시 알림
- 결과 요약

## 고급 설정

### Feeds 커스터마이징

다양한 데이터 소스에 대한 커스텀 피드 생성:

```python
# 커스텀 Slack Feed 예시
@subscriber.on_context_update(namespaces=["raw.slack"])
async def slack_feed(update: ContextUpdate):
    message = update.context.data
    
    # 긴급 멘션 필터링
    if "@urgent" in message["text"] or message["user"] in IMPORTANT_USERS:
        processed_signal = {
            "content": f"{message['user']}의 긴급 Slack 메시지: {message['text']}",
            "priority": "high",
            "source": "slack"
        }
        
        await context_store.store(
            data=processed_signal,
            namespace="signals.processed"
        )
```

### Scheduler 우선순위 조정

Scheduler에서 이벤트 우선순위 수정:

```python
def determine_priority(event_data):
    """커스텀 우선순위 로직"""
    if "urgent" in event_data.get("content", "").lower():
        return 1  # 최고 우선순위
    elif event_data.get("source") == "email":
        return 2
    elif event_data.get("source") == "calendar":
        return 3
    else:
        return 4  # 최저 우선순위
```

### 커스텀 Workers 생성

특정 작업을 위한 전문화된 워커 구축:

```python
class DataAnalysisWorker(StatefulWorker):
    """데이터 분석 작업에 특화된 Worker"""
    
    def __init__(self):
        super().__init__()
        self.tools = [
            "run_sql_query",
            "generate_visualization",
            "calculate_statistics"
        ]
    
    async def execute_task(self, task_description):
        # 존재하는 경우 이전 상태 로드
        state = await self.load_state()
        
        # 분석 수행
        result = await self.run_analysis(task_description)
        
        # 상태 저장
        await self.save_state(result)
        
        # scheduler에 반환
        return result
```

## 문제 해결

### 일반적인 문제

#### 1. Gmail 승인 실패

**문제**: Gmail 액세스를 승인할 수 없음

**해결책**:
```bash
# 기존 자격 증명 삭제
rm -rf ~/.credentials/pepper/

# 승인 재실행
python -m pepper.services.email_service
```

#### 2. Episodic 서버가 실행되지 않음

**문제**: `Connection refused to localhost:8000`

**해결책**:
```bash
# episodic이 실행 중인지 확인
ps aux | grep episodic

# 실행 중이 아니면 시작
conda activate pepper
episodic serve --port 8000
```

#### 3. API 키 누락

**문제**: `API key not found` 오류

**해결책**:
```bash
# 환경 변수가 로드되었는지 확인
echo $OPENAI_API_KEY
echo $COMPOSIO_API_KEY

# 비어 있으면 환경 재로드
source env_var.sh
```

#### 4. 첫 실행이 너무 오래 걸림

**문제**: 초기 프로필 구축이 2분 초과

**해결책**:
- 최초 설정에는 정상입니다
- 시스템 리소스(CPU, 메모리) 확인
- 안정적인 인터넷 연결 확인
- 인내심을 가지고 기다리세요—이후 실행은 더 빠릅니다

## 모범 사례

### 1. 이메일 관리

- **필터 구성**: Gmail에서 이메일 필터를 설정하여 노이즈 감소
- **중요 연락처**: 중요한 발신자를 VIP로 표시
- **요약 검토**: Pepper의 요약을 매일 확인
- **우선순위 조정**: "중요함"의 기준을 세밀하게 조정

### 2. 컨텍스트 관리

- **정기 정리**: 주기적으로 오래된 컨텍스트 데이터 정리
- **네임스페이스 구성**: 명확한 네임스페이스 규칙 사용
- **상태 버전 관리**: 롤백 기능을 위한 에이전트 상태 버전 관리

### 3. Worker 최적화

- **작업 세분성**: 큰 작업을 작은 청크로 분할
- **타임아웃 설정**: 장시간 실행 작업에 합리적인 타임아웃 설정
- **오류 처리**: 워커에 견고한 오류 복구 구현

### 4. 보안

- **API 키 순환**: 정기적으로 API 키 순환
- **액세스 제어**: 가능하면 Gmail 범위를 읽기 전용으로 제한
- **감사 로그**: Pepper의 작업을 정기적으로 모니터링
- **데이터 프라이버시**: 이메일의 민감한 정보에 유의

## 성능 최적화

### 1. Scheduler 튜닝

```python
# 이벤트 처리를 위한 배치 크기 조정
SCHEDULER_BATCH_SIZE = 5  # 사이클당 5개 이벤트 처리

# 최대 큐 크기 설정
MAX_QUEUE_SIZE = 100  # 메모리 문제 방지
```

### 2. Context Store 최적화

```bash
# 시맨틱 검색 캐싱 활성화
export EPISODIC_CACHE_ENABLED=true
export EPISODIC_CACHE_TTL=3600  # 1시간
```

### 3. Worker 풀 관리

```python
# 워커 풀 크기 구성
MAX_CONCURRENT_WORKERS = 10
WORKER_TIMEOUT = 300  # 5분
```

## 전통적인 어시스턴트와의 비교

| 기능 | 전통적인 챗봇 | Pepper |
|------|-------------|--------|
| **상호작용 모델** | 반응형 (프롬프트 대기) | 프로액티브 (지속적 모니터링) |
| **작업 처리** | 순차적 | 병렬 |
| **컨텍스트 인식** | 대화로 제한 | 다중 소스의 전체 컨텍스트 |
| **응답 시간** | 즉시이지만 제한적 | 백그라운드 처리 + 즉시 알림 |
| **도구 실행** | 동기식 (블로킹) | 비동기식 (논블로킹) |
| **메모리** | 세션 기반 | 세션 간 지속 |
| **확장성** | 단일 대화 | 다중 병렬 작업 |

## 향후 개선 사항

Pepper의 아키텍처는 흥미로운 미래 기능을 가능하게 합니다:

### 1. 예측 Feeds

이벤트가 발생하기 전에 필요를 예측하는 Feeds:
- 캘린더 초대 수락 _전에_ 회의 준비 스케줄링
- 항공권 예약 즉시 여행 서류 준비
- 일반적인 이메일 패턴에 대한 초안 응답 작성

### 2. 다중 사용자 협업

공유 Pepper 인스턴스로 팀 작업:
- 협업 작업 관리
- 공유 컨텍스트 및 지식 베이스
- 팀 전체 알림 및 요약

### 3. 고급 학습

사용자 행동에서 학습하는 Pepper:
- 개인화된 우선순위 설정
- 커스텀 자동화 규칙
- 행동 패턴 인식

## 리소스

### 공식 링크

- **GitHub 리포지토리**: [github.com/agentica-org/pepper](https://github.com/agentica-org/pepper)
- **블로그 포스트**: [Pepper 아키텍처 심층 분석](https://agentica-project.com/post.html?post=pepper.md)
- **Agentica 프로젝트**: [agentica-project.com](https://agentica-project.com)
- **Berkeley Sky Computing Lab**: 프로젝트를 지원하는 연구소

### 관련 기술

- **Episodic SDK**: [github.com/agentica-org/episodic-sdk](https://github.com/agentica-org/episodic-sdk)
- **Composio**: [composio.dev](https://composio.dev)
- **OpenAI API**: [platform.openai.com](https://platform.openai.com)

### 추가 읽기

1. [분산 시스템에서의 이벤트 드리븐 아키텍처](https://miladezzat.medium.com/event-driven-architecture-how-to-implement-in-distributed-systems-29bd82b02ace)
2. [ChatGPT Pulse: 차세대 프로액티브 AI](https://openai.com/index/introducing-chatgpt-pulse/)
3. [Uber의 Michelangelo ML 플랫폼](https://www.uber.com/blog/michelangelo-machine-learning-platform/)

## 결론

Pepper는 AI 어시스턴트 기술의 패러다임 전환을 나타냅니다. 수동적인 응답자에서 프로액티브 파트너로의 전환입니다. Sense-Think-Act 루프를 활용한 이벤트 드리븐 아키텍처를 통해 Pepper는 지속적으로 여러분을 위해 일하며, 백그라운드에서 복잡한 작업을 처리하면서 정말 중요한 것에 대한 정보를 제공합니다.

Pepper의 오픈소스 특성과 모듈식 아키텍처는 차세대 에이전틱 시스템을 실험하기에 이상적인 플랫폼을 만듭니다. 이메일 관리 자동화, 커스텀 워크플로우 구축, 실시간 AI 오케스트레이션 탐색 등 무엇을 찾든 Pepper는 견고한 기반을 제공합니다.

**핵심 요약:**

✅ Pepper는 AI 어시스턴스를 반응형에서 프로액티브로 변환  
✅ 이벤트 드리븐 아키텍처는 병렬, 논블로킹 작업 실행 가능  
✅ 모듈식 설계(Feeds, Scheduler, Workers, Context Store)로 쉬운 커스터마이징  
✅ Gmail 통합으로 즉각적인 실용적 가치 제공  
✅ Berkeley의 Agentica 팀이 적극적으로 개발하는 오픈소스

## 감사의 말

Pepper는 **Berkeley Sky Computing Lab**의 일환으로 **Agentica 팀**이 개발했으며, **Laude Institute**의 지원과 **AWS** 및 **Hyperbolic**의 컴퓨팅 그랜트를 받았습니다.

---

**질문이나 피드백이 있으신가요?** GitHub에서 프로젝트에 기여하거나 커뮤니티 토론에 참여하세요!

🔗 **GitHub**: [github.com/agentica-org/pepper](https://github.com/agentica-org/pepper)  
📧 **연락처**: 커뮤니티 채널은 리포지토리를 확인하세요

**다음 단계:**
- 이 가이드를 따라 Pepper 인스턴스 설정
- 코드베이스 탐색 및 피드 커스터마이징
- 특정 작업을 위한 자체 워커 구축
- 커뮤니티와 경험 공유!

즐거운 개발 되세요! 🚀


