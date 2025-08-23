---
title: "100% 로컬 환경에서 200개 이상의 데이터 소스를 연결하는 MCP 서버 구축 가이드: MindsDB, Cursor, Docker 활용"
date: 2024-05-31
categories: 
  - tutorials
tags: 
  - MCP
  - MindsDB
  - Cursor
  - Docker
  - 데이터통합
  - AI
author_profile: true
toc: true
toc_label: "목차"
---

오늘 우리는 200개가 넘는 방대한 로컬 데이터 소스에 연결할 수 있는 강력한 MCP(MindsDB Control Protocol) 서버를 구축하는 여정을 시작하겠습니다. 이 서버는 분산된 데이터를 통합적으로 관리하고 활용하는 데 핵심적인 역할을 수행할 것입니다.

시작하기 전에, 우리가 구축할 시스템의 간단한 데모를 상상해 보십시오. 여러 데이터베이스, API, 파일 시스템에 흩어져 있는 정보를 마치 하나의 거대한 데이터베이스처럼 쿼리하고, AI 에이전트가 이 통합된 정보에 접근하여 사용자에게 맥락에 맞는 답변을 제공하는 모습입니다.

## 주요 기술 스택

- **MindsDB**: 통합 MCP 서버의 두뇌 역할을 수행합니다. 데이터 소스 연결, 쿼리 연합, AI/ML 모델 통합 기능을 제공합니다.
- **Cursor AI**: MCP 호스트로서, 사용자와 MCP 서버 간의 인터페이스 역할을 합니다.
- **Docker**: MindsDB 서버를 자체 호스팅하기 위한 컨테이너화 환경을 제공하여 배포와 관리를 용이하게 합니다.

## 전체 워크플로우

1. **사용자 쿼리 제출**: 사용자가 Cursor AI를 통해 질문이나 데이터 요청을 제출합니다.
2. **에이전트의 MindsDB MCP 서버 연결**: Cursor의 에이전트는 MindsDB MCP 서버에 연결하여 사용 가능한 도구(데이터 소스 및 기능)를 탐색합니다.
3. **적절한 도구 선택 및 호출**: 에이전트는 사용자 쿼리의 의도를 파악하고, 가장 적합한 데이터 소스 또는 기능을 선택하여 MindsDB를 통해 호출합니다.
4. **맥락 기반 응답 반환**: MindsDB는 요청된 데이터를 조회하거나 작업을 수행한 후 결과를 에이전트에게 반환하고, 에이전트는 이를 바탕으로 사용자에게 문맥적으로 관련된 최종 응답을 제공합니다.

이제 본격적으로 코드를 살펴보며 MCP 서버 구축을 시작하겠습니다!

---

## 1️⃣ Docker를 이용한 MindsDB 설정

MindsDB는 Docker 이미지를 공식적으로 제공하므로, 로컬 환경에 손쉽게 설치하고 실행할 수 있습니다.

터미널에서 다음 명령어를 실행하여 MindsDB Docker 이미지를 다운로드하고 컨테이너를 실행합니다.

### 🧱 전체 명령어 개요

```bash
docker run \
  --name mindsdb_container \
  -e MINDSDB_APIs='http,mcp' \
  -p 47334:47334 \
  -p 47337:47337 \
  mindsdb/mindsdb
```

### 🔍 세부 설명

| 구성 요소                    | 의미 및 역할                                                     |
| :--------------------------- | :--------------------------------------------------------------- |
| `docker run`                 | 새로운 Docker 컨테이너를 실행합니다.                                 |
| `--name mindsdb_container`   | 컨테이너의 이름을 `mindsdb_container`로 지정합니다.                   |
| `-e MINDSDB_APIs='http,mcp'` | 환경 변수를 설정합니다: MindsDB에서 활성화할 API를 `http`와 `mcp`로 지정합니다. |
| `-p 47334:47334`             | 호스트의 47334 포트를 컨테이너의 47334 포트에 매핑합니다 (**HTTP API 포트**). |
| `-p 47337:47337`             | 호스트의 47337 포트를 컨테이너의 47337 포트에 매핑합니다 (**MCP API 포트**).  |
| `mindsdb/mindsdb`            | 실행할 Docker 이미지 (MindsDB 공식 이미지)입니다.                       |

### 🛠️ 요약

이 명령어는 MindsDB를 다음과 같은 구성으로 실행합니다:

- `mindsdb_container`라는 이름의 컨테이너로 실행
- HTTP 및 MCP API 활성화
- API 접근을 위한 로컬-컨테이너 간 포트 매핑 설정
- MindsDB의 최신 공식 Docker 이미지를 기반으로 실행

### 🚀 Kubernetes 배포를 위한 YAML (선택 사항)

MindsDB Docker 실행 명령어를 기반으로, Kubernetes 환경에서 MindsDB를 배포할 수 있도록 **Deployment YAML**과 **Helm `values.yaml`** 형식으로 변환한 예시는 다음과 같습니다. 이는 프로덕션 환경이나 보다 복잡한 오케스트레이션이 필요한 경우 유용합니다.

**Kubernetes Deployment YAML:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mindsdb
  labels:
    app: mindsdb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mindsdb
  template:
    metadata:
      labels:
        app: mindsdb
    spec:
      containers:
        - name: mindsdb
          image: mindsdb/mindsdb
          ports:
            - containerPort: 47334 # HTTP API
            - containerPort: 47337 # MCP API
          env:
            - name: MINDSDB_APIs
              value: "http,mcp"
---
apiVersion: v1
kind: Service
metadata:
  name: mindsdb-service
spec:
  selector:
    app: mindsdb
  ports:
    - name: http
      port: 47334
      targetPort: 47334
    - name: mcp
      port: 47337
      targetPort: 47337
  type: ClusterIP # 필요시 LoadBalancer로 변경하여 외부 노출 가능
```

> **팁**: 클라우드 환경(예: EKS, GKE)에서 외부 접근을 허용하려면 `Service`의 `type`을 `LoadBalancer`로 변경하십시오.

**Helm `values.yaml` 예시:**

```yaml
replicaCount: 1

image:
  repository: mindsdb/mindsdb
  pullPolicy: IfNotPresent
  # tag: "" # 특정 버전 고정 시 사용

containerPorts:
  - name: http
    containerPort: 47334
  - name: mcp
    containerPort: 47337

env:
  - name: MINDSDB_APIs
    value: "http,mcp"

service:
  type: ClusterIP # 또는 LoadBalancer
  ports:
    - name: http
      port: 47334
      targetPort: 47334
    - name: mcp
      port: 47337
      targetPort: 47337
```

> **참고**: 위 `values.yaml` 파일을 사용하려면, 해당 값을 참조하는 Helm 차트의 `deployment.yaml` 및 `service.yaml` 템플릿이 필요합니다. Helm 차트 스캐폴딩을 통해 기본 구조를 생성할 수 있습니다.

### ✨ 옵션 참고

- `MINDSDB_APIs`: 활성화할 API를 쉼표로 구분하여 지정합니다 (예: `http`, `mcp`, `mysql`, `rest` 등).
- `47334`: MindsDB HTTP API의 기본 포트입니다. MindsDB 에디터 접근 및 REST API 호출에 사용됩니다.
- `47337`: MindsDB MCP (MindsDB Control Protocol) API의 기본 포트입니다. Cursor와 같은 에이전트가 MindsDB와 통신하는 데 사용됩니다.

---

## 2️⃣ MindsDB GUI 실행

Docker 컨테이너가 성공적으로 실행되면, 웹 브라우저를 열고 주소창에 `http://127.0.0.1:47334`를 입력하여 MindsDB 에디터에 접속합니다.

이 웹 인터페이스를 통해 다음과 같은 작업들을 수행할 수 있습니다:

- 다양한 데이터 소스(데이터베이스, API, 파일 등) 연결 설정
- 연결된 데이터 소스에 대한 SQL 쿼리 실행
- AI/ML 모델 생성 및 학습
- 예측 쿼리 실행

---

## 3️⃣ 데이터 소스 통합

이제 우리의 연합 쿼리 엔진(Federated Query Engine) 구축을 위해 MindsDB에 다양한 데이터 소스를 연결해 보겠습니다. 이번 예제에서는 Slack, Gmail, GitHub를 연동하여 각기 다른 플랫폼의 데이터를 MindsDB를 통해 통합적으로 접근할 수 있도록 설정합니다.

MindsDB 에디터의 SQL 편집기 또는 MindsDB SDK를 사용하여 다음 SQL 명령을 실행합니다.

### 🔗 Slack 연결

Slack 채널의 메시지, 파일 등을 데이터 소스로 활용합니다.

```sql
CREATE DATABASE mindsdb_slack
WITH ENGINE = 'slack',
PARAMETERS = {
  "token": "xoxb-YOUR_SLACK_BOT_USER_OAUTH_TOKEN",
  "app_token": "xapp-YOUR_SLACK_APP_LEVEL_TOKEN"
};
```

- `ENGINE`: `'slack'`으로 지정합니다.
- `PARAMETERS`:
  - `token`: Slack Bot User OAuth Token (일반적으로 `xoxb-`로 시작)을 입력합니다.
  - `app_token`: Slack App-Level Token (일반적으로 `xapp-`로 시작)을 입력합니다.

### 📧 Gmail 연결

특정 라벨이 붙은 이메일이나 전체 받은 편지함의 내용을 데이터로 활용합니다.

```sql
CREATE DATABASE mindsdb_gmail
WITH ENGINE = 'gmail',
PARAMETERS = {
  "credentials_file": "path/to/your/credentials.json"
};
```

- `ENGINE`: `'gmail'`으로 지정합니다.
- `PARAMETERS`:
  - `credentials_file`: Google Cloud Platform에서 발급받은 Gmail API용 OAuth 2.0 클라이언트 인증 정보 JSON 파일의 로컬 경로를 지정합니다. MindsDB Docker 컨테이너가 접근할 수 있는 경로여야 합니다 (예: Docker 볼륨 마운트 활용).

### 🐙 GitHub 연결

특정 GitHub 저장소의 이슈, 커밋, PR 등의 데이터를 조회합니다.

```sql
CREATE DATABASE mindsdb_github
WITH ENGINE = 'github',
PARAMETERS = {
  "repository": "username/repository_name"
  -- "token": "YOUR_GITHUB_PERSONAL_ACCESS_TOKEN" -- (Optional, for private repos or higher rate limits)
};
```

- `ENGINE`: `'github'`으로 지정합니다.
- `PARAMETERS`:
  - `repository`: 조회하고자 하는 GitHub 저장소의 경로를 `username/repository_name` 형식으로 지정합니다.
  - `token` (선택 사항): 비공개 저장소에 접근하거나 API 요청 제한을 늘리려면 GitHub Personal Access Token을 여기에 추가할 수 있습니다.

> **중요**: 위 SQL 예제에서 `YOUR_..._TOKEN` 및 `path/to/your/credentials.json`, `username/repository_name` 부분은 실제 사용자의 환경에 맞게 수정해야 합니다. 또한, 200개 이상의 데이터 소스 연결은 MindsDB가 지원하는 다양한 [데이터 통합(Integrations)](https://docs.mindsdb.com/integrations/data-integrations) 문서를 참고하여 유사한 방식으로 `CREATE DATABASE` 구문을 사용하여 확장할 수 있습니다.

---

## 4️⃣ MCP 서버와 Cursor 통합

연합 쿼리 엔진을 구축하고 데이터 소스를 MindsDB에 연결했다면, 이제 이들을 MindsDB의 MCP 서버를 통해 Cursor AI와 통합할 차례입니다. 이를 통해 Cursor 내에서 MindsDB에 연결된 모든 데이터 소스를 마치 단일화된 지식 베이스처럼 활용할 수 있게 됩니다.

Cursor AI 애플리케이션에서 다음 단계를 따릅니다:

1. **File** 메뉴로 이동합니다.
2. **Preferences** (또는 Settings)를 선택합니다.
3. **Cursor Settings**를 클릭합니다.
4. 왼쪽 메뉴에서 **MCP** (MindsDB Control Protocol) 섹션을 찾습니다.
5. **Add new global MCP server** 버튼을 클릭합니다.

그러면 JSON 설정 파일이 열립니다. 이 파일에 다음과 같이 MindsDB MCP 서버 정보를 추가합니다:

```json
{
  "mcpServers": {
    "mindsdb": {
      "url": "http://127.0.0.1:47337/sse"
    }
  }
}
```

- `mindsdb`: MCP 서버의 별칭입니다 (원하는 이름으로 변경 가능).
- `url`: MindsDB MCP 서버의 SSE(Server-Sent Events) 엔드포인트 주소입니다. Docker 설정 시 `-p 47337:47337`로 포트 매핑을 했으므로, 로컬 주소는 `http://127.0.0.1:47337/sse`가 됩니다.

설정을 저장하면 완료입니다! 이제 MindsDB MCP 서버가 활성화되고 Cursor AI에 성공적으로 연결되었습니다. 🚀

이 MCP 서버는 Cursor AI 에이전트에게 다음과 같은 두 가지 핵심 도구를 제공합니다:

- `list_databases`: MindsDB에 연결된 모든 데이터 소스(데이터베이스)의 목록을 반환합니다. 에이전트는 이를 통해 어떤 데이터를 활용할 수 있는지 파악합니다.
- `query`: 사용자의 질문을 바탕으로 연합된 데이터에 대해 SQL과 유사한 쿼리를 실행하고 그 결과를 반환합니다. 에이전트는 이 도구를 사용하여 실제 데이터 조회 및 분석을 수행합니다.

---

## 마무리

이로써 우리는 100% 로컬 환경에서 MindsDB, Cursor, Docker를 활용하여 200개 이상의 데이터 소스와 연결 가능한 강력한 MCP 서버를 구축하는 방법을 상세히 살펴보았습니다. 이 아키텍처를 통해 분산된 데이터를 효과적으로 통합하고, AI 기반 에이전트가 이 정보에 쉽게 접근하여 더욱 스마트한 상호작용을 제공할 수 있는 기반을 마련했습니다.

이제 여러분의 다양한 데이터 소스를 연결하고, Cursor AI와 함께 새로운 데이터 활용 가능성을 탐색해 보시기 바랍니다!
