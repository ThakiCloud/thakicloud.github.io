---
title: "Kubernetes 환경에서 Prometheus와 Grafana로 모니터링 시스템 구축하기"
date: 2025-06-13
categories: 
  - dev
  - kubernetes
tags: 
  - kubernetes
  - prometheus
  - grafana
  - monitoring
  - observability
  - devops
author_profile: true
toc: true
toc_label: "목차"
---

Kubernetes 클러스터의 효율적인 운영을 위해서는 노드, 파드, 컨테이너 수준의 상세한 모니터링이 필수입니다.
Prometheus와 Grafana를 활용해 K8s 환경에서 완전한 모니터링 시스템을 구축하는 방법을 단계별로 안내합니다.

## 모니터링 아키텍처 개요

우리가 구축할 모니터링 시스템은 다음 구성 요소들로 이루어집니다:

- **Prometheus**: 메트릭 수집 및 저장
- **Grafana**: 시각화 및 대시보드
- **Node Exporter**: 노드 수준 메트릭 수집
- **cAdvisor**: 컨테이너 수준 메트릭 수집
- **Kube State Metrics**: Kubernetes 오브젝트 상태 메트릭

## 전제 조건

시작하기 전에 다음 요구사항을 확인하세요:

- Kubernetes 클러스터 (v1.20 이상)
- kubectl 명령어 접근 권한
- Helm 3.x 설치
- 클러스터 관리자 권한

## Prometheus 설치 및 구성

### Helm을 통한 Prometheus 설치

먼저 Prometheus 커뮤니티 Helm 차트를 사용하여 설치합니다. 아래 명령어를 **터미널에 복사해서 한 줄씩 실행**하세요.

```bash
# Prometheus Helm 저장소 추가
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# monitoring 네임스페이스 생성
kubectl create namespace monitoring

# Prometheus 설치
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false
```

설치가 끝나면 아래 명령어로 파드 상태를 확인하세요.

```bash
kubectl get pods -n monitoring
```

## Node Exporter 구성

Node Exporter는 kube-prometheus-stack에 이미 포함되어 있습니다. 각 노드에서 수집되는 주요 메트릭을 확인하려면 아래와 같이 진행하세요.

### 주요 노드 메트릭

- **CPU 사용률**: `node_cpu_seconds_total`
- **메모리 사용량**: `node_memory_MemAvailable_bytes`
- **디스크 사용량**: `node_filesystem_size_bytes`
- **네트워크 트래픽**: `node_network_receive_bytes_total`

#### (선택) Node Exporter Collector 설정 파일 생성

**이 파일은 Node Exporter가 어떤 메트릭을 수집할지 지정하는 ConfigMap입니다.**

아래 명령어를 터미널에 복사해서 실행하면 `node-exporter-config.yaml` 파일이 생성됩니다.

```bash
cat <<EOF > node-exporter-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: node-exporter-config
  namespace: monitoring
data:
  config.yaml: |
    collectors:
      - cpu
      - diskstats
      - filesystem
      - loadavg
      - meminfo
      - netdev
      - stat
      - time
      - uname
EOF
```

생성한 파일을 아래 명령어로 적용하세요.

```bash
kubectl apply -f node-exporter-config.yaml
```

## 컨테이너 메트릭 수집 구성

### cAdvisor 설정

**cAdvisor는 각 노드의 컨테이너 리소스 사용량을 수집하는 역할을 합니다.**

아래 명령어를 터미널에 복사해서 실행하면 `cadvisor-servicemonitor.yaml` 파일이 생성됩니다.

```bash
cat <<EOF > cadvisor-servicemonitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: cadvisor
  namespace: monitoring
  labels:
    app: cadvisor
spec:
  selector:
    matchLabels:
      app: cadvisor
  endpoints:
  - port: http-metrics
    interval: 30s
    path: /metrics/cadvisor
EOF
```

생성한 파일을 아래 명령어로 적용하세요.

```bash
kubectl apply -f cadvisor-servicemonitor.yaml
```

### 주요 컨테이너 메트릭

- **CPU 사용률**: `container_cpu_usage_seconds_total`
- **메모리 사용량**: `container_memory_usage_bytes`
- **네트워크 I/O**: `container_network_receive_bytes_total`
- **파일시스템 사용량**: `container_fs_usage_bytes`

## Grafana 대시보드 구성

### Grafana 접속

**Grafana는 시각화 도구로, 웹 브라우저에서 대시보드를 볼 수 있습니다.**

아래 명령어를 터미널에 입력하면, 로컬 PC에서 Grafana 웹 UI에 접속할 수 있습니다.

```bash
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
```

- **URL**: http://localhost:3000
- **기본 계정**: admin / prom-operator

### 노드 모니터링 대시보드 예시

아래 전체를 복사해서 Grafana의 "Import"에서 붙여넣으세요.

```json
{
  "id": null,
  "uid": null,
  "title": "Kubernetes Node Monitoring (Sample)",
  "timezone": "browser",
  "schemaVersion": 36,
  "version": 1,
  "refresh": "10s",
  "panels": [
    {
      "type": "graph",
      "title": "Node CPU Usage (%)",
      "id": 1,
      "datasource": "Prometheus",
      "targets": [
        {
          "expr": "100 - (avg by (instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
          "legendFormat": "{{instance}}",
          "interval": ""
        }
      ],
      "yaxes": [
        {
          "format": "percent",
          "label": "CPU Usage",
          "logBase": 1,
          "max": 100,
          "min": 0,
          "show": true
        },
        {
          "format": "short",
          "show": true
        }
      ]
    },
    {
      "type": "graph",
      "title": "Node Memory Usage (%)",
      "id": 2,
      "datasource": "Prometheus",
      "targets": [
        {
          "expr": "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100",
          "legendFormat": "{{instance}}",
          "interval": ""
        }
      ],
      "yaxes": [
        {
          "format": "percent",
          "label": "Memory Usage",
          "logBase": 1,
          "max": 100,
          "min": 0,
          "show": true
        },
        {
          "format": "short",
          "show": true
        }
      ]
    }
  ]
}
```

### 컨테이너 모니터링 대시보드 예시

아래 전체를 복사해서 Grafana의 "Import"에서 붙여넣으세요.

```json
{
  "id": null,
  "uid": null,
  "title": "Kubernetes Container Monitoring (Sample)",
  "timezone": "browser",
  "schemaVersion": 36,
  "version": 1,
  "refresh": "10s",
  "panels": [
    {
      "type": "graph",
      "title": "Container CPU Usage (%)",
      "id": 1,
      "datasource": "Prometheus",
      "targets": [
        {
          "expr": "rate(container_cpu_usage_seconds_total{container!=\"POD\",container!=\"\"}[5m]) * 100",
          "legendFormat": "{{pod}}/{{container}}",
          "interval": ""
        }
      ],
      "yaxes": [
        {
          "format": "percent",
          "label": "CPU Usage",
          "logBase": 1,
          "max": 100,
          "min": 0,
          "show": true
        },
        {
          "format": "short",
          "show": true
        }
      ]
    },
    {
      "type": "graph",
      "title": "Container Memory Usage (MB)",
      "id": 2,
      "datasource": "Prometheus",
      "targets": [
        {
          "expr": "container_memory_usage_bytes{container!=\"POD\",container!=""} / 1024 / 1024",
          "legendFormat": "{{pod}}/{{container}}",
          "interval": ""
        }
      ],
      "yaxes": [
        {
          "format": "megabytes",
          "label": "Memory Usage",
          "logBase": 1,
          "show": true
        },
        {
          "format": "short",
          "show": true
        }
      ]
    }
  ]
}
```

## 주요 PromQL 쿼리

Prometheus와 Grafana에서 사용할 수 있는 주요 쿼리 예시입니다. 각 쿼리는 실제로 동작하는 쿼리이며, 초보자도 이해할 수 있도록 설명을 추가했습니다.

### 노드 메트릭 쿼리

```promql
# 1. CPU 사용률 (5분 평균)
# 각 노드의 CPU 사용률(%)을 5분 평균으로 보여줍니다. 값이 높을수록 CPU를 많이 사용 중입니다.
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# 2. 메모리 사용률
# 각 노드의 전체 메모리 중 사용 중인 비율(%)을 보여줍니다.
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# 3. 디스크 사용률
# 각 노드의 디스크(파일시스템) 사용률(%)을 보여줍니다. tmpfs(임시 파일시스템)는 제외합니다.
(1 - (node_filesystem_avail_bytes{fstype!="tmpfs"} / node_filesystem_size_bytes{fstype!="tmpfs"})) * 100
```

### 컨테이너 메트릭 쿼리

```promql
# 1. 컨테이너 CPU 사용률
# 각 컨테이너의 CPU 사용률(%)을 5분 평균으로 보여줍니다. (POD, 빈 컨테이너 제외)
rate(container_cpu_usage_seconds_total{container!="POD",container!=""}[5m]) * 100

# 2. 컨테이너 메모리 사용량 (MB)
# 각 컨테이너의 메모리 사용량을 MB 단위로 보여줍니다.
container_memory_usage_bytes{container!="POD",container!=""} / 1024 / 1024

# 3. 네임스페이스별 파드 수
# 각 네임스페이스에 존재하는 파드의 개수를 집계합니다.
count by (namespace) (kube_pod_info)
```

## 알람 설정

### PrometheusRule 구성

**PrometheusRule은 특정 조건(예: CPU 사용률 80% 초과)에서 알람을 발생시키는 역할을 합니다.**

아래 명령어를 터미널에 복사해서 실행하면 `monitoring-alerts.yaml` 파일이 생성됩니다.

```bash
cat <<EOF > monitoring-alerts.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: monitoring-alerts
  namespace: monitoring
spec:
  groups:
  - name: node-alerts
    rules:
    - alert: NodeHighCPUUsage
      expr: 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: "High CPU usage detected on {{ $labels.instance }}"
    - alert: NodeHighMemoryUsage
      expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: "High memory usage detected on {{ $labels.instance }}"
  - name: container-alerts
    rules:
    - alert: ContainerHighMemoryUsage
      expr: container_memory_usage_bytes{container!="POD",container!=""} / container_spec_memory_limit_bytes > 0.9
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: "Container {{ $labels.container }} in pod {{ $labels.pod }} is using high memory"
EOF
```

생성한 파일을 아래 명령어로 적용하세요.

```bash
kubectl apply -f monitoring-alerts.yaml
```

## 성능 최적화

### Prometheus 스토리지 구성

**Prometheus의 메트릭 데이터를 영구적으로 저장하려면 PersistentVolumeClaim을 생성해야 합니다.**

아래 명령어를 터미널에 복사해서 실행하면 `prometheus-storage.yaml` 파일이 생성됩니다.

```bash
cat <<EOF > prometheus-storage.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prometheus-storage
  namespace: monitoring
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
  storageClassName: fast-ssd
EOF
```

생성한 파일을 아래 명령어로 적용하세요.

```bash
kubectl apply -f prometheus-storage.yaml
```

### 메트릭 수집 간격 조정

**Prometheus의 메트릭 수집 주기와 평가 주기를 조정하려면 아래와 같이 설정 파일을 만듭니다.**

아래 명령어를 터미널에 복사해서 실행하면 `prometheus-config.yaml` 파일이 생성됩니다.

```bash
cat <<EOF > prometheus-config.yaml
global:
  scrape_interval: 30s
  evaluation_interval: 30s

scrape_configs:
  - job_name: 'kubernetes-nodes'
    scrape_interval: 30s
    kubernetes_sd_configs:
      - role: node
EOF
```

생성한 파일을 아래 명령어로 적용하세요.

```bash
kubectl apply -f prometheus-config.yaml
```

## 트러블슈팅

### 일반적인 문제와 해결책

1. **메트릭이 수집되지 않는 경우**:
   - Prometheus 파드의 로그를 확인하세요.
   ```bash
   kubectl logs -n monitoring prometheus-prometheus-kube-prometheus-prometheus-0
   ```
2. **Grafana 대시보드가 표시되지 않는 경우**:
   - 서비스 상태를 확인하세요.
   ```bash
   kubectl get svc -n monitoring
   kubectl describe svc prometheus-grafana -n monitoring
   ```
3. **Prometheus의 높은 메모리 사용량**:
   - Helm values 파일에서 아래와 같이 retention 설정을 추가하세요.
   ```yaml
   prometheus:
     prometheusSpec:
       retention: 7d
       retentionSize: 50GB
   ```

## 모니터링 베스트 프랙티스

### 라벨링 전략

효율적인 메트릭 관리를 위해 리소스에 라벨을 붙이는 것이 중요합니다. 아래는 예시입니다.

```yaml
# 애플리케이션 라벨
app: "my-app"
version: "v1.2.3"
environment: "production"
team: "backend"

# 인프라 라벨
cluster: "prod-cluster-01"
zone: "us-west-2a"
instance_type: "m5.large"
```

### 대시보드 구성 권장사항

- **계층적 구조**: 클러스터 → 노드 → 파드 → 컨테이너
- **시간 범위 일관성**: 모든 패널에 동일한 시간 범위 적용
- **색상 코딩**: 상태별 일관된 색상 사용 (정상: 녹색, 경고: 주황, 위험: 빨강)

## 결론

Kubernetes 환경에서 Prometheus와 Grafana를 활용한 완전한 모니터링 시스템을 구축함으로써 다음을 달성할 수 있습니다:

- **실시간 모니터링**: 노드와 컨테이너 수준의 상세한 메트릭 추적
- **프로액티브 알람**: 문제 발생 전 미리 감지하고 대응
- **시각적 인사이트**: 직관적인 대시보드를 통한 시스템 상태 파악
- **성능 최적화**: 리소스 사용 패턴 분석을 통한 최적화 방향 도출

이러한 모니터링 시스템을 통해 Kubernetes 클러스터의 안정성과 성능을 크게 향상시킬 수 있으며, 운영 효율성도 높일 수 있습니다. 

## 실습 후 리소스 정리 방법

실습이 끝난 후, 생성한 리소스(예: ServiceMonitor, PrometheusRule 등)를 정리하려면 아래 명령어를 사용하세요.

```bash
kubectl delete -f cadvisor-servicemonitor.yaml
kubectl delete -f monitoring-alerts.yaml
kubectl delete -f node-exporter-config.yaml
kubectl delete -f prometheus-storage.yaml
kubectl delete -f prometheus-config.yaml
```

Helm으로 설치한 kube-prometheus-stack까지 삭제하려면:

```bash
helm uninstall prometheus -n monitoring
kubectl delete namespace monitoring
```

> ⚠️ **주의:** 위 명령어를 실행하면 관련 리소스와 네임스페이스가 모두 삭제되니, 실습 환경에서만 사용하세요. 