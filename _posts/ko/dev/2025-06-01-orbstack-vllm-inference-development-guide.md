---
title: "OrbStack으로 시작하는 vLLM 추론 서비스 개발 - 신입 개발자를 위한 완벽 가이드"
date: 2025-06-01
categories: 
  - dev
tags: 
  - orbstack
  - vllm
  - kubernetes
  - helm
  - llm-inference
  - macos
  - docker
  - ai-development
  - beginner-guide
author_profile: true
toc: true
toc_label: "목차"
published: false
---

macOS에서 AI 모델 추론 서비스를 개발할 때 Docker Desktop은 무겁고 리소스를 많이 사용합니다. **OrbStack**은 이런 문제를 해결해주는 혁신적인 대안입니다. 이번 포스트에서는 OrbStack을 사용해 가볍고 빠른 Kubernetes 환경을 구축하고, Helm을 활용해 vLLM 추론 서비스를 개발하는 전 과정을 신입 개발자 관점에서 상세히 안내해드리겠습니다.

## OrbStack이란?

**OrbStack**은 macOS와 Linux를 위한 차세대 Docker Desktop 대안입니다. 기존 Docker Desktop 대비 다음과 같은 장점이 있습니다:

### OrbStack vs Docker Desktop

| 특징 | OrbStack | Docker Desktop |
|------|----------|----------------|
| **시작 시간** | 2-3초 | 30-60초 |
| **메모리 사용량** | 50% 적음 | 높음 |
| **CPU 사용량** | 최적화됨 | 높음 |
| **파일 시스템** | 네이티브 성능 | 느림 |
| **Kubernetes** | 내장 지원 | 별도 설정 필요 |

### 주요 특징

- **빠른 시작**: 몇 초 만에 컨테이너 실행
- **낮은 리소스 사용**: 메모리와 CPU 효율성
- **네이티브 성능**: macOS와 완벽 통합
- **내장 Kubernetes**: 별도 설정 없이 즉시 사용
- **직관적 UI**: 사용하기 쉬운 인터페이스

## 개발 환경 설정

### 1. OrbStack 설치

#### 공식 웹사이트에서 다운로드

```bash
# 공식 웹사이트에서 다운로드
open https://orbstack.dev/download

# 또는 Homebrew로 설치
brew install orbstack
```

#### 설치 후 초기 설정

```bash
# OrbStack 실행
open -a OrbStack

# 설치 확인
orb version

# Docker 명령어 확인
docker version

# Kubernetes 확인
kubectl version --client
```

### 2. 필수 도구 설치

#### Helm 설치

```bash
# Homebrew로 Helm 설치
brew install helm

# 설치 확인
helm version
```

#### 기타 유용한 도구들

```bash
# k9s (Kubernetes 클러스터 모니터링)
brew install k9s

# kubectx (컨텍스트 전환)
brew install kubectx

# stern (로그 스트리밍)
brew install stern

# yq (YAML 처리)
brew install yq
```

### 3. OrbStack Kubernetes 클러스터 설정

#### Kubernetes 활성화

```bash
# OrbStack에서 Kubernetes 활성화
orb start k8s

# 클러스터 상태 확인
kubectl cluster-info

# 노드 확인
kubectl get nodes

# 컨텍스트 확인
kubectl config current-context
```

#### 네임스페이스 생성

```bash
# vLLM 전용 네임스페이스 생성
kubectl create namespace vllm-system

# 기본 네임스페이스 설정
kubectl config set-context --current --namespace=vllm-system
```

## vLLM Helm Chart 개발

### 1. Helm Chart 구조 생성

```bash
# 프로젝트 디렉토리 생성
mkdir -p ~/vllm-orbstack-project
cd ~/vllm-orbstack-project

# Helm Chart 생성
helm create vllm-inference

# Chart 구조 확인
brew install tree
tree vllm-inference/
```

### 2. Chart.yaml 설정

```yaml
# vllm-inference/Chart.yaml
apiVersion: v2
name: vllm-inference
description: A Helm chart for vLLM inference service on OrbStack
type: application
version: 0.1.0
appVersion: "latest"

keywords:
  - vllm
  - llm
  - inference
  - ai

maintainers:
  - name: Your Name
    email: your.email@example.com

dependencies: []
```

### 3. values.yaml 설정

```yaml
# vllm-inference/values.yaml
# 기본 설정
replicaCount: 2

image:
  repository: vllm/vllm-openai
  pullPolicy: IfNotPresent
  tag: "latest"

# 서비스 설정
service:
  type: ClusterIP
  port: 8000
  targetPort: 8000

# Ingress 설정
ingress:
  enabled: true
  className: ""
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/proxy-read-timeout: "300"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "300"
  hosts:
    - host: vllm.local
      paths:
        - path: /
          pathType: Prefix
  tls: []

# vLLM 설정 (macOS CPU 전용)
vllm:
  model: "bartowski/deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-GGUF"
  modelFile: "deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-Q4_0.gguf"
  host: "0.0.0.0"
  port: 8000
  maxModelLen: 4096
  maxTokens: 1024
  logLevel: "INFO"
  # CPU 전용 설정
  cpuOnly: true
  ompNumThreads: 4

# 리소스 설정 (macOS CPU 최적화)
resources:
  limits:
    cpu: 4000m
    memory: 12Gi
  requests:
    cpu: 2000m
    memory: 6Gi

# 오토스케일링 설정
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80

# 헬스체크 설정
healthCheck:
  enabled: true
  livenessProbe:
    httpGet:
      path: /health
      port: 8000
    initialDelaySeconds: 60
    periodSeconds: 30
    timeoutSeconds: 10
  readinessProbe:
    httpGet:
      path: /health
      port: 8000
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 5

# 보안 설정
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000

# 노드 선택기
nodeSelector: {}

# 톨러레이션
tolerations: []

# 어피니티
affinity: {}

# 환경변수
env: []

# 볼륨 마운트
volumeMounts: []

# 볼륨
volumes: []
```

### 4. Deployment 템플릿 작성

{% raw %}

```yaml
# vllm-inference/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "vllm-inference.fullname" . }}
  labels:
    {{- include "vllm-inference.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "vllm-inference.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
      labels:
        {{- include "vllm-inference.selectorLabels" . | nindent 8 }}
    spec:
      securityContext:
        {{- toYaml .Values.securityContext | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.service.targetPort }}
          env:
            - name: MODEL_NAME
              value: {{ .Values.vllm.model | quote }}
            - name: MODEL_FILE
              value: {{ .Values.vllm.modelFile | quote }}
            - name: HOST
              value: {{ .Values.vllm.host | quote }}
            - name: PORT
              value: {{ .Values.vllm.port | quote }}
            - name: MAX_MODEL_LEN
              value: {{ .Values.vllm.maxModelLen | quote }}
            - name: MAX_TOKENS
              value: {{ .Values.vllm.maxTokens | quote }}
            - name: LOG_LEVEL
              value: {{ .Values.vllm.logLevel | quote }}
            # CPU 전용 환경변수
            - name: VLLM_CPU_ONLY
              value: "1"
            - name: OMP_NUM_THREADS
              value: {{ .Values.vllm.ompNumThreads | quote }}
            - name: MKL_NUM_THREADS
              value: {{ .Values.vllm.ompNumThreads | quote }}
            - name: NUMEXPR_NUM_THREADS
              value: {{ .Values.vllm.ompNumThreads | quote }}
            - name: PYTHONUNBUFFERED
              value: "1"
          {{- if .Values.healthCheck.enabled }}
          livenessProbe:
            {{- toYaml .Values.healthCheck.livenessProbe | nindent 12 }}
          readinessProbe:
            {{- toYaml .Values.healthCheck.readinessProbe | nindent 12 }}
          {{- end }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          {{- with .Values.volumeMounts }}
          volumeMounts:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          command:
            - python
            - -m
            - vllm.entrypoints.openai.api_server
            - --model
            - $(MODEL_NAME)
            - --revision
            - main
            - --host
            - $(HOST)
            - --port
            - $(PORT)
            - --max-model-len
            - $(MAX_MODEL_LEN)
            - --max-num-seqs
            - "8"
            - --dtype
            - auto
            - --enforce-eager
            - --disable-log-requests
            - --cpu-only
      {{- with .Values.volumes }}
      volumes:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
```

{% endraw %}

### 5. Service 템플릿 작성

{% raw %}

```yaml
# vllm-inference/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "vllm-inference.fullname" . }}
  labels:
    {{- include "vllm-inference.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
      protocol: TCP
      name: http
  selector:
    {{- include "vllm-inference.selectorLabels" . | nindent 4 }}
```

{% endraw %}

### 6. Ingress 템플릿 작성

{% raw %}

```yaml
# vllm-inference/templates/ingress.yaml
{{- if .Values.ingress.enabled -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "vllm-inference.fullname" . }}
  labels:
    {{- include "vllm-inference.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.ingress.className }}
  ingressClassName: {{ .Values.ingress.className }}
  {{- end }}
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType }}
            backend:
              service:
                name: {{ include "vllm-inference.fullname" $ }}
                port:
                  number: {{ $.Values.service.port }}
          {{- end }}
    {{- end }}
{{- end }}
```

{% endraw %}

### 7. HPA 템플릿 작성

{% raw %}

```yaml
# vllm-inference/templates/hpa.yaml
{{- if .Values.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "vllm-inference.fullname" . }}
  labels:
    {{- include "vllm-inference.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "vllm-inference.fullname" . }}
  minReplicas: {{ .Values.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.autoscaling.maxReplicas }}
  metrics:
    {{- if .Values.autoscaling.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
    {{- end }}
    {{- if .Values.autoscaling.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetMemoryUtilizationPercentage }}
    {{- end }}
{{- end }}
```

{% endraw %}

### 8. ConfigMap 템플릿 작성

{% raw %}

```yaml
# vllm-inference/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "vllm-inference.fullname" . }}-config
  labels:
    {{- include "vllm-inference.labels" . | nindent 4 }}
data:
  model: {{ .Values.vllm.model | quote }}
  model-file: {{ .Values.vllm.modelFile | quote }}
  host: {{ .Values.vllm.host | quote }}
  port: {{ .Values.vllm.port | quote }}
  max-model-len: {{ .Values.vllm.maxModelLen | quote }}
  max-tokens: {{ .Values.vllm.maxTokens | quote }}
  log-level: {{ .Values.vllm.logLevel | quote }}
  # CPU 전용 설정
  cpu-only: "true"
  omp-num-threads: {{ .Values.vllm.ompNumThreads | quote }}
  vllm-cpu-only: "1"
```

{% endraw %}

## Helm Chart 배포 및 테스트

### 1. Chart 유효성 검사

```bash
# Chart 문법 검사
helm lint vllm-inference/

# 템플릿 렌더링 테스트
helm template vllm-inference vllm-inference/ --debug

# 드라이런 테스트
helm install vllm-inference vllm-inference/ --dry-run --debug
```

### 2. Chart 배포

```bash
# Helm Chart 설치
helm install vllm-inference vllm-inference/ \
  --namespace vllm-system \
  --create-namespace

# 배포 상태 확인
helm status vllm-inference -n vllm-system

# 배포된 리소스 확인
kubectl get all -n vllm-system
```

### 3. 배포 모니터링

```bash
# Pod 상태 실시간 모니터링
kubectl get pods -n vllm-system -w

# 로그 확인
kubectl logs -f deployment/vllm-inference -n vllm-system

# k9s로 클러스터 모니터링
k9s -n vllm-system
```

## 개발 워크플로우

### 1. 로컬 개발 환경 설정

```bash
# 개발용 values 파일 생성
cat > values-dev.yaml << EOF
replicaCount: 1

image:
  repository: vllm/vllm-openai
  tag: latest
  pullPolicy: IfNotPresent

vllm:
  model: "bartowski/deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-GGUF"
  modelFile: "deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-Q4_0.gguf"
  maxModelLen: 4096
  maxTokens: 1024
  logLevel: "DEBUG"
  # CPU 전용 설정
  cpuOnly: true
  ompNumThreads: 2

resources:
  limits:
    cpu: 2000m
    memory: 8Gi
  requests:
    cpu: 1000m
    memory: 4Gi

autoscaling:
  enabled: false

ingress:
  enabled: true
  hosts:
    - host: vllm-dev.local
      paths:
        - path: /
          pathType: Prefix
EOF
```

### 2. 개발용 배포

```bash
# 개발 환경 배포
helm install vllm-dev vllm-inference/ \
  -f values-dev.yaml \
  --namespace vllm-dev \
  --create-namespace

# 포트 포워딩으로 로컬 테스트
kubectl port-forward service/vllm-dev 8000:8000 -n vllm-dev
```

### 3. API 테스트 스크립트

```python
#!/usr/bin/env python3
"""vLLM API 테스트 스크립트 for OrbStack"""

import requests
import json
import time
from typing import Dict, Any, List

class VLLMTester:
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url
        self.session = requests.Session()
        
    def test_health(self) -> bool:
        """헬스체크 테스트"""
        try:
            response = self.session.get(f"{self.base_url}/health", timeout=5)
            print(f"✅ 헬스체크: HTTP {response.status_code}")
            return response.status_code == 200
        except Exception as e:
            print(f"❌ 헬스체크 실패: {e}")
            return False
    
    def test_models(self) -> bool:
        """모델 목록 조회 테스트"""
        try:
            response = self.session.get(f"{self.base_url}/v1/models", timeout=10)
            if response.status_code == 200:
                models = response.json()
                print(f"✅ 사용 가능한 모델: {len(models.get('data', []))}개")
                for model in models.get('data', []):
                    print(f"  - {model.get('id', 'Unknown')}")
                return True
            else:
                print(f"❌ 모델 조회 실패: HTTP {response.status_code}")
                return False
        except Exception as e:
            print(f"❌ 모델 조회 오류: {e}")
            return False
    
    def test_completion(self, prompt: str = "Hello, how are you?") -> bool:
        """텍스트 완성 테스트"""
        try:
            payload = {
                "model": "bartowski/deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-GGUF",
                "prompt": prompt,
                "max_tokens": 50,
                "temperature": 0.7,
                "stream": False
            }
            
            response = self.session.post(
                f"{self.base_url}/v1/completions",
                json=payload,
                headers={"Content-Type": "application/json"},
                timeout=30
            )
            
            if response.status_code == 200:
                result = response.json()
                print("✅ 텍스트 완성 성공:")
                print(f"  입력: {payload['prompt']}")
                print(f"  출력: {result['choices'][0]['text'].strip()}")
                return True
            else:
                print(f"❌ 텍스트 완성 실패: HTTP {response.status_code}")
                print(f"  응답: {response.text}")
                return False
        except Exception as e:
            print(f"❌ 텍스트 완성 오류: {e}")
            return False
    
    def test_streaming_completion(self, prompt: str = "Tell me a story") -> bool:
        """스트리밍 완성 테스트"""
        try:
            payload = {
                "model": "bartowski/deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-GGUF",
                "prompt": prompt,
                "max_tokens": 100,
                "temperature": 0.7,
                "stream": True
            }
            
            response = self.session.post(
                f"{self.base_url}/v1/completions",
                json=payload,
                headers={"Content-Type": "application/json"},
                stream=True,
                timeout=30
            )
            
            if response.status_code == 200:
                print("✅ 스트리밍 완성 성공:")
                print(f"  입력: {prompt}")
                print("  출력: ", end="")
                
                for line in response.iter_lines():
                    if line:
                        line_str = line.decode('utf-8')
                        if line_str.startswith('data: '):
                            data_str = line_str[6:]
                            if data_str.strip() == '[DONE]':
                                break
                            try:
                                data = json.loads(data_str)
                                if 'choices' in data and data['choices']:
                                    text = data['choices'][0].get('text', '')
                                    print(text, end='', flush=True)
                            except json.JSONDecodeError:
                                continue
                print()
                return True
            else:
                print(f"❌ 스트리밍 완성 실패: HTTP {response.status_code}")
                return False
        except Exception as e:
            print(f"❌ 스트리밍 완성 오류: {e}")
            return False
    
    def benchmark_performance(self, num_requests: int = 10) -> Dict[str, float]:
        """성능 벤치마크 테스트"""
        print(f"🚀 성능 벤치마크 시작 ({num_requests}개 요청)...")
        
        times = []
        successful_requests = 0
        
        for i in range(num_requests):
            start_time = time.time()
            
            payload = {
                "model": "bartowski/deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-GGUF",
                "prompt": f"Request {i+1}: What is AI?",
                "max_tokens": 30,
                "temperature": 0.7
            }
            
            try:
                response = self.session.post(
                    f"{self.base_url}/v1/completions",
                    json=payload,
                    timeout=30
                )
                
                if response.status_code == 200:
                    successful_requests += 1
                    
                end_time = time.time()
                request_time = end_time - start_time
                times.append(request_time)
                
                print(f"  요청 {i+1}/{num_requests}: {request_time:.2f}s")
                
            except Exception as e:
                print(f"  요청 {i+1}/{num_requests}: 실패 - {e}")
        
        if times:
            avg_time = sum(times) / len(times)
            min_time = min(times)
            max_time = max(times)
            
            print(f"\n📊 벤치마크 결과:")
            print(f"  성공률: {successful_requests}/{num_requests} ({successful_requests/num_requests*100:.1f}%)")
            print(f"  평균 응답 시간: {avg_time:.2f}s")
            print(f"  최소 응답 시간: {min_time:.2f}s")
            print(f"  최대 응답 시간: {max_time:.2f}s")
            print(f"  처리량: {successful_requests/sum(times):.2f} req/s")
            
            return {
                "success_rate": successful_requests/num_requests,
                "avg_time": avg_time,
                "min_time": min_time,
                "max_time": max_time,
                "throughput": successful_requests/sum(times)
            }
        else:
            print("❌ 모든 요청이 실패했습니다.")
            return {}
    
    def run_all_tests(self):
        """모든 테스트 실행"""
        print("🧪 vLLM API 테스트 시작 (OrbStack 환경)\n")
        
        tests = [
            ("헬스체크", self.test_health),
            ("모델 목록", self.test_models),
            ("텍스트 완성", lambda: self.test_completion("안녕하세요! 오늘 날씨가 어떤가요?")),
            ("스트리밍 완성", lambda: self.test_streaming_completion("간단한 이야기를 들려주세요"))
        ]
        
        results = []
        for test_name, test_func in tests:
            print(f"🔍 {test_name} 테스트 중...")
            result = test_func()
            results.append((test_name, result))
            print()
            time.sleep(1)
        
        # 성능 벤치마크
        print("🔍 성능 벤치마크 테스트 중...")
        benchmark_results = self.benchmark_performance(5)
        print()
        
        print("📊 테스트 결과 요약:")
        for test_name, result in results:
            status = "✅ 성공" if result else "❌ 실패"
            print(f"  {test_name}: {status}")
        
        success_count = sum(1 for _, result in results if result)
        print(f"\n🎯 총 {len(results)}개 테스트 중 {success_count}개 성공")
        
        if benchmark_results:
            print(f"⚡ 평균 응답 시간: {benchmark_results['avg_time']:.2f}s")
            print(f"🚀 처리량: {benchmark_results['throughput']:.2f} req/s")

if __name__ == "__main__":
    import sys
    
    base_url = "http://localhost:8000"
    if len(sys.argv) > 1:
        base_url = sys.argv[1]
    
    print(f"🎯 테스트 대상: {base_url}")
    tester = VLLMTester(base_url)
    tester.run_all_tests()
```

### 4. 테스트 실행

```bash
# 테스트 스크립트 실행
python test_vllm_orbstack.py

# 또는 특정 URL로 테스트
python test_vllm_orbstack.py http://vllm-dev.local
```

## 모니터링 및 로깅

### 1. Prometheus 모니터링 설정

```yaml
# monitoring/prometheus-values.yaml
prometheus:
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false
    serviceMonitorSelector: {}
    ruleSelector: {}
    
grafana:
  enabled: true
  adminPassword: admin123
  
alertmanager:
  enabled: true
```

```bash
# Prometheus 스택 설치
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install monitoring prometheus-community/kube-prometheus-stack \
  -f monitoring/prometheus-values.yaml \
  --namespace monitoring \
  --create-namespace
```

### 2. vLLM ServiceMonitor 생성

{% raw %}

```yaml
# vllm-inference/templates/servicemonitor.yaml
{{- if .Values.monitoring.enabled }}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ include "vllm-inference.fullname" . }}
  labels:
    {{- include "vllm-inference.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "vllm-inference.selectorLabels" . | nindent 6 }}
  endpoints:
  - port: http
    path: /metrics
    interval: 30s
    scrapeTimeout: 10s
{{- end }}
```

{% endraw %}

### 3. Grafana 대시보드

```json
# monitoring/vllm-dashboard.json
{
  "dashboard": {
    "id": null,
    "title": "vLLM Inference Metrics",
    "tags": ["vllm", "inference"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Request Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "rate(vllm_requests_total[5m])",
            "legendFormat": "Requests/sec"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "reqps"
          }
        }
      },
      {
        "id": 2,
        "title": "Response Time",
        "type": "timeseries",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(vllm_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          },
          {
            "expr": "histogram_quantile(0.50, rate(vllm_request_duration_seconds_bucket[5m]))",
            "legendFormat": "50th percentile"
          }
        ]
      },
      {
        "id": 3,
        "title": "Memory Usage",
        "type": "timeseries",
        "targets": [
          {
            "expr": "container_memory_usage_bytes{pod=~\"vllm-inference-.*\"}",
            "legendFormat": "Memory Usage"
          }
        ]
      },
      {
        "id": 4,
        "title": "CPU Usage",
        "type": "timeseries",
        "targets": [
          {
            "expr": "rate(container_cpu_usage_seconds_total{pod=~\"vllm-inference-.*\"}[5m])",
            "legendFormat": "CPU Usage"
          }
        ]
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "5s"
  }
}
```

## 성능 최적화

### 1. OrbStack 최적화 설정 (macOS CPU 전용)

```bash
# OrbStack 리소스 할당 확인
orb config

# CPU 및 메모리 할당 조정 (CPU 집약적 워크로드용)
orb config set cpu 8
orb config set memory 16GB

# 디스크 공간 확인 (DeepSeek 모델은 큰 용량)
orb config set disk 100GB

# CPU 최적화 설정
orb config set vm.cpuType "host"
orb config set vm.accelerated true
```

### 2. Helm Chart 성능 튜닝 (macOS CPU 최적화)

```yaml
# values-production.yaml
replicaCount: 4

image:
  repository: vllm/vllm-openai
  tag: latest
  pullPolicy: IfNotPresent

vllm:
  model: "bartowski/deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-GGUF"
  modelFile: "deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-Q4_0.gguf"
  maxModelLen: 4096
  maxTokens: 2048
  logLevel: "INFO"
  # CPU 전용 최적화
  cpuOnly: true
  ompNumThreads: 6

resources:
  limits:
    cpu: 6000m
    memory: 16Gi
  requests:
    cpu: 3000m
    memory: 8Gi

autoscaling:
  enabled: true
  minReplicas: 4
  maxReplicas: 20
  targetCPUUtilizationPercentage: 60
  targetMemoryUtilizationPercentage: 70

# 노드 어피니티 설정 (macOS 호환성)
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/arch
          operator: In
          values:
          - amd64
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
            - vllm-inference
        topologyKey: kubernetes.io/hostname

# 리소스 쿼터 설정
resourceQuota:
  enabled: true
  hard:
    requests.cpu: "15"
    requests.memory: 50Gi
    limits.cpu: "30"
    limits.memory: 100Gi
```

### 3. 캐싱 전략

{% raw %}

```yaml
# vllm-inference/templates/redis.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "vllm-inference.fullname" . }}-redis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379
        resources:
          limits:
            cpu: 500m
            memory: 1Gi
          requests:
            cpu: 100m
            memory: 256Mi
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "vllm-inference.fullname" . }}-redis
spec:
  selector:
    app: redis
  ports:
  - port: 6379
    targetPort: 6379
```

{% endraw %}

## CI/CD 파이프라인

### 1. GitHub Actions 워크플로우

```yaml
# .github/workflows/deploy-orbstack.yml
name: Deploy vLLM to OrbStack

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: $`github.repository`/vllm-inference

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        pip install pytest requests
    
    - name: Run tests
      run: |
        pytest tests/
  
  lint:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Helm Lint
      run: |
        helm lint vllm-inference/
    
    - name: Validate Kubernetes manifests
      run: |
        helm template vllm-inference vllm-inference/ | kubectl apply --dry-run=client -f -

  build:
    needs: [test, lint]
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
    
    - name: Log in to Container Registry
      uses: docker/login-action@v3
      with:
        registry: ${{ env.REGISTRY }}
        username: $`github.actor`
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=sha
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}

  deploy-dev:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    environment: development
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Helm
      uses: azure/setup-helm@v3
      with:
        version: '3.12.0'
    
    - name: Deploy to development
      run: |
        helm upgrade --install vllm-dev vllm-inference/ \
          --namespace vllm-dev \
          --create-namespace \
          --set image.tag=$`github.sha` \
          -f values-dev.yaml

  deploy-prod:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Helm
      uses: azure/setup-helm@v3
      with:
        version: '3.12.0'
    
    - name: Deploy to production
      run: |
        helm upgrade --install vllm-prod vllm-inference/ \
          --namespace vllm-system \
          --create-namespace \
          --set image.tag=$`github.sha` \
          -f values-production.yaml
```

### 2. 배포 스크립트

```bash
#!/bin/bash
# scripts/deploy.sh

set -e

ENVIRONMENT=${1:-dev}
NAMESPACE="vllm-${ENVIRONMENT}"
VALUES_FILE="values-${ENVIRONMENT}.yaml"

echo "🚀 vLLM 배포 시작 (환경: ${ENVIRONMENT})"

# 네임스페이스 확인/생성
if ! kubectl get namespace ${NAMESPACE} >/dev/null 2>&1; then
    echo "📦 네임스페이스 생성: ${NAMESPACE}"
    kubectl create namespace ${NAMESPACE}
fi

# Helm Chart 유효성 검사
echo "🔍 Helm Chart 검증 중..."
helm lint vllm-inference/

# 배포 실행
echo "📦 배포 실행 중..."
helm upgrade --install vllm-${ENVIRONMENT} vllm-inference/ \
    --namespace ${NAMESPACE} \
    -f ${VALUES_FILE} \
    --wait \
    --timeout 10m

# 배포 상태 확인
echo "✅ 배포 완료! 상태 확인 중..."
kubectl get pods -n ${NAMESPACE}
kubectl get services -n ${NAMESPACE}

# 헬스체크
echo "🏥 헬스체크 실행 중..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=vllm-inference -n ${NAMESPACE} --timeout=300s

echo "🎉 배포 성공!"
```

## 문제 해결 가이드

### 자주 발생하는 문제들

#### 1. OrbStack 관련 문제 (macOS CPU 환경)

```bash
# OrbStack 상태 확인
orb status

# CPU 사용률 확인
orb stats

# OrbStack 재시작 (CPU 성능 최적화)
orb restart

# 로그 확인
orb logs

# CPU 리소스 사용량 실시간 모니터링
orb exec -- top -n 1
```

#### 2. Kubernetes 클러스터 문제 (CPU 환경)

```bash
# 클러스터 상태 확인
kubectl cluster-info

# 노드 리소스 상태 확인 (CPU 중심)
kubectl top nodes
kubectl describe nodes

# CPU 사용률이 높은 Pod 확인
kubectl top pods --sort-by=cpu -A

# 이벤트 확인
kubectl get events --sort-by='.lastTimestamp' -n vllm-system
```

#### 3. DeepSeek 모델 로딩 문제

```bash
# DeepSeek 모델 다운로드 상태 확인
helm status vllm-inference -n vllm-system

# GGUF 모델 다운로드 진행상황
kubectl logs -f deployment/vllm-inference -n vllm-system | grep -i "download\|loading\|model"

# 모델 파일 크기 확인 (DeepSeek Q4_0은 약 4.8GB)
kubectl exec -it deployment/vllm-inference -n vllm-system -- \
  du -h /root/.cache/huggingface/hub/ | grep deepseek

# 허깅페이스 연결 테스트
kubectl exec -it deployment/vllm-inference -n vllm-system -- \
  curl -I https://huggingface.co/bartowski/deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-GGUF

# GGUF 파일 무결성 검사
kubectl exec -it deployment/vllm-inference -n vllm-system -- \
  python -c "
from huggingface_hub import hf_hub_download
import os
file_path = hf_hub_download(
    repo_id='bartowski/deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-GGUF',
    filename='deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-Q4_0.gguf'
)
print(f'GGUF File size: {os.path.getsize(file_path)/1024/1024/1024:.2f} GB')
"
```

#### 4. CPU 리소스 부족 문제

```bash
# Helm 릴리스 리소스 조정
helm upgrade vllm-inference vllm-inference/ \
  --set resources.limits.cpu=6000m \
  --set resources.limits.memory=16Gi \
  --set resources.requests.cpu=3000m \
  --set resources.requests.memory=8Gi \
  -n vllm-system

# OrbStack VM 리소스 증가
orb config set cpu 12
orb config set memory 24GB
orb restart

# CPU 사용률 모니터링
kubectl exec -it deployment/vllm-inference -n vllm-system -- \
  top -n 1 -b | head -20
```

#### 5. GGUF 모델 형식 관련 문제

```bash
# vLLM GGUF 지원 확인
kubectl exec -it deployment/vllm-inference -n vllm-system -- \
  python -c "
import vllm
print(f'vLLM version: {vllm.__version__}')
try:
    from vllm import LLM
    print('GGUF support: Available')
except Exception as e:
    print(f'GGUF support: Error - {e}')
"

# 지원되는 모델 형식 확인
kubectl exec -it deployment/vllm-inference -n vllm-system -- \
  python -c "
from vllm.model_executor.models import MODEL_REGISTRY
print('Supported models:')
for model in sorted(MODEL_REGISTRY.keys()):
    print(f'  - {model}')
"
```

## 결론

OrbStack을 사용한 CPU 기반 vLLM DeepSeek 추론 서비스 개발은 기존 Docker Desktop 대비 다음과 같은 장점을 제공합니다:

### 핵심 장점 요약

1. **빠른 시작**: 2-3초 만에 CPU 최적화 컨테이너 환경 준비
2. **낮은 리소스 사용**: macOS에서 메모리와 CPU 효율성 극대화
3. **네이티브 성능**: Apple Silicon과 Intel Mac 모두에서 최적 성능
4. **DeepSeek GGUF 모델**: 고성능 양자화 모델로 빠른 추론
5. **Helm 활용**: 체계적인 CPU 기반 Kubernetes 애플리케이션 관리
6. **실시간 모니터링**: CPU 사용률 중심의 성능 모니터링

### 개발 워크플로우

1. **로컬 개발**: OrbStack + Helm으로 CPU 최적화 개발 환경 구축
2. **GGUF 모델 테스트**: DeepSeek 양자화 모델을 통한 효율적 추론
3. **CPU 기반 배포**: Helm Chart를 통한 일관된 CPU 전용 배포
4. **성능 모니터링**: CPU 사용률과 메모리 효율성 실시간 추적
5. **리소스 최적화**: macOS 환경에 맞는 CPU 및 메모리 튜닝

### macOS 특화 이점

- **개발 환경 통합**: 맥북에서 개발부터 배포까지 seamless 경험
- **리소스 효율성**: GPU 없이도 DeepSeek GGUF로 충분한 추론 성능
- **OrbStack 최적화**: Docker Desktop 대비 50% 적은 리소스 사용
- **플랫폼 호환성**: Apple Silicon과 Intel Mac 모두 지원
- **모델 효율성**: GGUF 형식으로 빠른 로딩과 적은 메모리 사용

### 다음 단계

- **모델 확장**: 더 큰 DeepSeek 모델 (16B, 32B) 활용
- **멀티 모델 서빙**: 여러 GGUF 모델 동시 운영
- **동적 스케일링**: CPU 코어 수에 따른 자동 스케일링
- **클라우드 하이브리드**: 로컬 개발 + 클라우드 CPU 인스턴스 배포
- **성능 벤치마크**: 다양한 GGUF 양자화 레벨 비교

OrbStack의 뛰어난 성능과 Helm의 강력한 패키지 관리 기능, 그리고 DeepSeek GGUF 모델의 효율성을 결합하여 macOS에서 최고의 CPU 기반 AI 추론 서비스를 구축해보세요!

---

*이 가이드는 OrbStack 1.0+, Helm 3.12+, vLLM 0.4.x (CPU 지원) 버전을 기준으로 작성되었습니다.*
