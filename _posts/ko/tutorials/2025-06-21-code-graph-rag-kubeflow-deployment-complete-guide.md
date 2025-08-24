---
title: "Code Graph RAG: 코드베이스를 위한 지식 그래프 RAG 시스템 완전 가이드"
excerpt: "Python 코드베이스를 분석하여 지식 그래프를 구축하고, 자연어로 질의할 수 있는 RAG 시스템을 Kubeflow에 배포하는 방법을 단계별로 설명합니다."
date: 2025-06-21
categories: 
  - tutorials
  - llmops
tags: 
  - RAG
  - Knowledge Graph
  - Memgraph
  - Kubeflow
  - Python
  - AST
  - Gemini
  - Code Analysis
author_profile: true
toc: true
toc_label: "Code Graph RAG 가이드"
---

## 개요

Code Graph RAG는 Python 코드베이스를 분석하여 지식 그래프를 구축하고, 자연어로 코드 구조와 관계를 질의할 수 있는 정교한 RAG(Retrieval-Augmented Generation) 시스템입니다. 이 가이드에서는 로컬 설치부터 Kubeflow를 통한 프로덕션 배포까지 전체 과정을 다룹니다.

## 시스템 아키텍처

### 핵심 구성 요소

- **Repository Parser**: Python 코드베이스를 AST 기반으로 분석
- **Knowledge Graph**: Memgraph를 사용한 코드 구조 저장
- **RAG System**: 자연어 질의를 위한 대화형 CLI
- **LLM Integration**: Google Gemini를 통한 자연어 처리

### 지원 기능

- AST 기반 코드 분석 (클래스, 함수, 메서드 추출)
- 지식 그래프 저장 및 관계 매핑
- 자연어 질의 처리
- AI 기반 Cypher 쿼리 생성
- 실제 소스 코드 스니펫 검색
- 의존성 분석 (`pyproject.toml` 파싱)

## 로컬 환경 설정

### 사전 요구사항

```bash
# 필수 소프트웨어 확인
python --version  # Python 3.12+
docker --version
docker-compose --version
uv --version
```

### 프로젝트 설치

```bash
# 1. 저장소 클론
git clone https://github.com/vitali87/code-graph-rag.git
cd code-graph-rag

# 2. 의존성 설치
uv sync

# 3. 환경 변수 설정
cp .env.example .env
```

### 환경 변수 구성

`.env` 파일을 다음과 같이 설정합니다:

```bash
# Google Gemini API 설정
GEMINI_API_KEY=your-gemini-api-key
GEMINI_MODEL_ID=gemini-2.0-flash-exp

# Memgraph 데이터베이스 설정
MEMGRAPH_HOST=localhost
MEMGRAPH_PORT=7687

# 대상 저장소 경로
TARGET_REPO_PATH=/path/to/your/python/repo
```

### Memgraph 데이터베이스 시작

```bash
# Docker Compose로 Memgraph 실행
docker-compose up -d

# 연결 확인
docker-compose ps
```

## 기본 사용법

### 1단계: 코드베이스 파싱

```bash
# Python 저장소 분석 및 지식 그래프 생성
python repo_parser.py /path/to/your/python/repo --clean

# 옵션 설명:
# --clean: 기존 데이터 삭제 후 새로 파싱
# --host: Memgraph 호스트 (기본값: localhost)
# --port: Memgraph 포트 (기본값: 7687)
```

### 2단계: RAG 시스템 실행

```bash
# 대화형 질의 시스템 시작
python -m codebase_rag.main --repo-path /path/to/your/repo
```

### 질의 예시

```bash
# 클래스 검색
"Show me all classes that contain 'user' in their name"

# 함수 검색
"Find functions related to database operations"

# 메서드 검색
"What methods does the User class have?"

# 인증 관련 코드 검색
"Show me functions that handle authentication"

# 의존성 분석
"What external packages does this project depend on?"
```

## 지식 그래프 스키마

### 노드 유형

- **Project**: 저장소 루트 노드
- **Package**: Python 패키지 (\_\_init\_\_.py 포함 디렉토리)
- **Module**: 개별 Python 파일
- **Class**: 클래스 정의
- **Function**: 모듈 레벨 함수
- **Method**: 클래스 메서드
- **Folder**: 일반 디렉토리
- **File**: 비-Python 파일
- **ExternalPackage**: 외부 의존성

### 관계 유형

```cypher
# 계층적 포함 관계
(Project)-[:CONTAINS_PACKAGE]->(Package)
(Package)-[:CONTAINS_MODULE]->(Module)
(Module)-[:CONTAINS_FILE]->(File)

# 정의 관계
(Module)-[:DEFINES]->(Class)
(Module)-[:DEFINES]->(Function)
(Class)-[:DEFINES_METHOD]->(Method)

# 의존성 관계
(Project)-[:DEPENDS_ON_EXTERNAL]->(ExternalPackage)
```

## 고급 사용법

### 커스텀 파서 작성

```python
# custom_parser.py
import ast
from pathlib import Path
from codebase_rag.services.graph_db import GraphDB

class CustomCodeParser:
    def __init__(self, graph_db: GraphDB):
        self.graph_db = graph_db
    
    def parse_decorators(self, node: ast.FunctionDef):
        """데코레이터 정보 추출"""
        decorators = []
        for decorator in node.decorator_list:
            if isinstance(decorator, ast.Name):
                decorators.append(decorator.id)
            elif isinstance(decorator, ast.Call):
                decorators.append(ast.unparse(decorator))
        return decorators
    
    def parse_type_hints(self, node: ast.FunctionDef):
        """타입 힌트 정보 추출"""
        annotations = {}
        for arg in node.args.args:
            if arg.annotation:
                annotations[arg.arg] = ast.unparse(arg.annotation)
        
        if node.returns:
            annotations['return'] = ast.unparse(node.returns)
        
        return annotations
```

### 배치 처리 스크립트

```python
# batch_process.py
import asyncio
from pathlib import Path
from codebase_rag.services.graph_db import GraphDB
from repo_parser import RepositoryParser

async def batch_process_repositories(repo_paths: list[str]):
    """여러 저장소를 배치로 처리"""
    graph_db = GraphDB()
    parser = RepositoryParser(graph_db)
    
    for repo_path in repo_paths:
        print(f"Processing {repo_path}...")
        try:
            await parser.parse_repository(Path(repo_path))
            print(f"✅ Completed {repo_path}")
        except Exception as e:
            print(f"❌ Failed {repo_path}: {e}")

# 사용 예시
if __name__ == "__main__":
    repos = [
        "/path/to/repo1",
        "/path/to/repo2",
        "/path/to/repo3"
    ]
    asyncio.run(batch_process_repositories(repos))
```

## Kubeflow 배포 가이드

### 1단계: Kubeflow 클러스터 준비

```bash
# Kubeflow 설치 (Minikube 예시)
minikube start --cpus 4 --memory 8192 --disk-size 40g

# Kubeflow 배포
kustomize build example | kubectl apply -f -

# 포트 포워딩으로 접근
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80
```

### 2단계: 컨테이너 이미지 빌드

```dockerfile
# Dockerfile
FROM python:3.12-slim

WORKDIR /app

# 시스템 의존성 설치
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Python 의존성 설치
COPY pyproject.toml uv.lock ./
RUN pip install uv && uv sync --frozen

# 애플리케이션 코드 복사
COPY . .

# 실행 권한 설정
RUN chmod +x repo_parser.py

# 기본 명령어
CMD ["python", "-m", "codebase_rag.main"]
```

```bash
# 이미지 빌드 및 푸시
docker build -t your-registry/code-graph-rag:latest .
docker push your-registry/code-graph-rag:latest
```

### 3단계: Kubeflow Pipeline 정의

```python
# pipeline.py
import kfp
from kfp import dsl
from kfp.components import create_component_from_func

@create_component_from_func
def parse_repository_op(
    repo_url: str,
    memgraph_host: str,
    memgraph_port: int = 7687
) -> str:
    """저장소 파싱 컴포넌트"""
    import subprocess
    import os
    
    # 저장소 클론
    subprocess.run(['git', 'clone', repo_url, '/tmp/repo'], check=True)
    
    # 환경 변수 설정
    os.environ['MEMGRAPH_HOST'] = memgraph_host
    os.environ['MEMGRAPH_PORT'] = str(memgraph_port)
    
    # 파싱 실행
    result = subprocess.run([
        'python', 'repo_parser.py', 
        '/tmp/repo', '--clean'
    ], capture_output=True, text=True)
    
    return f"Parsing completed: {result.stdout}"

@create_component_from_func
def setup_memgraph_op(
    memgraph_image: str = "memgraph/memgraph:latest"
) -> str:
    """Memgraph 설정 컴포넌트"""
    import subprocess
    
    # Memgraph 컨테이너 실행
    cmd = [
        'docker', 'run', '-d',
        '--name', 'memgraph-instance',
        '-p', '7687:7687',
        memgraph_image
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    return f"Memgraph started: {result.stdout}"

@dsl.pipeline(
    name='Code Graph RAG Pipeline',
    description='코드베이스 분석 및 지식 그래프 구축 파이프라인'
)
def code_graph_rag_pipeline(
    repo_url: str,
    memgraph_host: str = "memgraph-service"
):
    """메인 파이프라인"""
    
    # Memgraph 설정
    memgraph_task = setup_memgraph_op()
    
    # 저장소 파싱
    parse_task = parse_repository_op(
        repo_url=repo_url,
        memgraph_host=memgraph_host
    )
    parse_task.after(memgraph_task)
    
    return parse_task
```

### 4단계: Kubernetes 리소스 정의

```yaml
# k8s-manifests.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: code-graph-rag-config
  namespace: kubeflow
data:
  MEMGRAPH_HOST: "memgraph-service"
  MEMGRAPH_PORT: "7687"
  GEMINI_MODEL_ID: "gemini-2.0-flash-exp"
---
apiVersion: v1
kind: Secret
metadata:
  name: code-graph-rag-secrets
  namespace: kubeflow
type: Opaque
data:
  GEMINI_API_KEY: <base64-encoded-api-key>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: memgraph-deployment
  namespace: kubeflow
spec:
  replicas: 1
  selector:
    matchLabels:
      app: memgraph
  template:
    metadata:
      labels:
        app: memgraph
    spec:
      containers:
      - name: memgraph
        image: memgraph/memgraph:latest
        ports:
        - containerPort: 7687
        resources:
          requests:
            memory: "2Gi"
            cpu: "1"
          limits:
            memory: "4Gi"
            cpu: "2"
        volumeMounts:
        - name: memgraph-data
          mountPath: /var/lib/memgraph
      volumes:
      - name: memgraph-data
        persistentVolumeClaim:
          claimName: memgraph-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: memgraph-service
  namespace: kubeflow
spec:
  selector:
    app: memgraph
  ports:
  - port: 7687
    targetPort: 7687
  type: ClusterIP
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: memgraph-pvc
  namespace: kubeflow
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

### 5단계: 배포 실행

```bash
# Kubernetes 리소스 배포
kubectl apply -f k8s-manifests.yaml

# 파이프라인 컴파일 및 업로드
python -c "
import kfp
from pipeline import code_graph_rag_pipeline

# 파이프라인 컴파일
kfp.compiler.Compiler().compile(
    pipeline_func=code_graph_rag_pipeline,
    package_path='code-graph-rag-pipeline.yaml'
)

# Kubeflow에 업로드
client = kfp.Client(host='http://localhost:8080')
client.upload_pipeline(
    pipeline_package_path='code-graph-rag-pipeline.yaml',
    pipeline_name='Code Graph RAG Pipeline'
)
"
```

### 6단계: 파이프라인 실행

```python
# run_pipeline.py
import kfp

# Kubeflow 클라이언트 초기화
client = kfp.Client(host='http://localhost:8080')

# 실험 생성
experiment = client.create_experiment(name='code-graph-rag-experiment')

# 파이프라인 실행
run = client.run_pipeline(
    experiment_id=experiment.id,
    job_name='code-graph-rag-run',
    pipeline_package_path='code-graph-rag-pipeline.yaml',
    params={
        'repo_url': 'https://github.com/your-org/your-repo.git',
        'memgraph_host': 'memgraph-service'
    }
)

print(f"Pipeline run started: {run.id}")
```

## 모니터링 및 운영

### 로그 확인

```bash
# Memgraph 로그 확인
kubectl logs -f deployment/memgraph-deployment -n kubeflow

# 파이프라인 실행 로그 확인
kubectl logs -f <pipeline-pod-name> -n kubeflow
```

### 성능 모니터링

```python
# monitoring.py
import time
import psutil
from codebase_rag.services.graph_db import GraphDB

class PerformanceMonitor:
    def __init__(self):
        self.graph_db = GraphDB()
    
    def monitor_parsing_performance(self, repo_path: str):
        """파싱 성능 모니터링"""
        start_time = time.time()
        start_memory = psutil.Process().memory_info().rss
        
        # 파싱 실행
        # ... parsing logic ...
        
        end_time = time.time()
        end_memory = psutil.Process().memory_info().rss
        
        metrics = {
            'parsing_time': end_time - start_time,
            'memory_usage': end_memory - start_memory,
            'repo_size': self._get_repo_size(repo_path)
        }
        
        return metrics
    
    def _get_repo_size(self, repo_path: str) -> int:
        """저장소 크기 계산"""
        total_size = 0
        for path in Path(repo_path).rglob('*.py'):
            total_size += path.stat().st_size
        return total_size
```

### 데이터베이스 백업

```bash
# Memgraph 데이터 백업
kubectl exec -it deployment/memgraph-deployment -n kubeflow -- \
  mg_snapshot --save /var/lib/memgraph/snapshots/backup-$(date +%Y%m%d).mg

# 백업 파일 로컬로 복사
kubectl cp kubeflow/memgraph-deployment-xxx:/var/lib/memgraph/snapshots/ ./backups/
```

## 트러블슈팅

### 일반적인 문제들

```bash
# 1. Memgraph 연결 실패
kubectl get pods -n kubeflow | grep memgraph
kubectl describe pod <memgraph-pod-name> -n kubeflow

# 2. 메모리 부족 오류
kubectl top pods -n kubeflow
kubectl describe node

# 3. 파이프라인 실행 실패
kubectl logs -f <pipeline-pod-name> -n kubeflow
```

### 디버깅 도구

```python
# debug_tools.py
from codebase_rag.services.graph_db import GraphDB

def debug_graph_structure():
    """그래프 구조 디버깅"""
    graph_db = GraphDB()
    
    # 노드 수 확인
    node_counts = graph_db.execute_query("""
        MATCH (n) 
        RETURN labels(n)[0] as label, count(n) as count
    """)
    
    print("Node counts:")
    for record in node_counts:
        print(f"  {record['label']}: {record['count']}")
    
    # 관계 수 확인
    rel_counts = graph_db.execute_query("""
        MATCH ()-[r]->() 
        RETURN type(r) as relationship, count(r) as count
    """)
    
    print("\nRelationship counts:")
    for record in rel_counts:
        print(f"  {record['relationship']}: {record['count']}")

def test_query_performance():
    """쿼리 성능 테스트"""
    graph_db = GraphDB()
    
    test_queries = [
        "MATCH (c:Class) RETURN count(c)",
        "MATCH (f:Function) RETURN count(f)",
        "MATCH (m:Method) RETURN count(m)"
    ]
    
    for query in test_queries:
        start_time = time.time()
        result = graph_db.execute_query(query)
        end_time = time.time()
        
        print(f"Query: {query}")
        print(f"Time: {end_time - start_time:.3f}s")
        print(f"Result: {list(result)}\n")
```

## 확장 및 커스터마이징

### 새로운 언어 지원 추가

```python
# language_parsers/javascript_parser.py
import json
from pathlib import Path

class JavaScriptParser:
    def __init__(self, graph_db):
        self.graph_db = graph_db
    
    def parse_javascript_file(self, file_path: Path):
        """JavaScript 파일 파싱"""
        # ESLint 또는 Babel 파서 사용
        # AST 생성 및 그래프 노드 생성
        pass
```

### 커스텀 질의 도구

```python
# custom_query_tool.py
from codebase_rag.tools.base import BaseTool

class CustomQueryTool(BaseTool):
    def __init__(self, graph_db):
        super().__init__(graph_db)
        self.name = "custom_query"
        self.description = "Execute custom Cypher queries"
    
    def execute(self, query: str) -> str:
        """커스텀 쿼리 실행"""
        try:
            results = self.graph_db.execute_query(query)
            return self._format_results(results)
        except Exception as e:
            return f"Query failed: {str(e)}"
    
    def _format_results(self, results) -> str:
        """결과 포맷팅"""
        formatted = []
        for record in results:
            formatted.append(dict(record))
        return json.dumps(formatted, indent=2)
```

## 결론

Code Graph RAG는 대규모 Python 코드베이스를 이해하고 탐색하는 강력한 도구입니다. 이 가이드를 통해 로컬 개발 환경에서 시작하여 Kubeflow를 통한 프로덕션 배포까지 전체 워크플로우를 구축할 수 있습니다.

주요 장점:
- **정확한 코드 분석**: AST 기반 파싱으로 정확한 구조 추출
- **유연한 질의**: 자연어를 통한 직관적인 코드 탐색
- **확장 가능한 아키텍처**: 다양한 언어와 도구 지원 가능
- **프로덕션 준비**: Kubeflow를 통한 확장 가능한 배포

이 시스템을 통해 개발팀은 복잡한 코드베이스를 더 효율적으로 이해하고 유지보수할 수 있습니다.

## 참고 자료

- [Code Graph RAG GitHub Repository](https://github.com/vitali87/code-graph-rag)
- [Memgraph Documentation](https://memgraph.com/docs)
- [Kubeflow Documentation](https://kubeflow.org/docs/)
- [Google Gemini API Guide](https://ai.google.dev/docs)
- [Python AST Module](https://docs.python.org/3/library/ast.html) 