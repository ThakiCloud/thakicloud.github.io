---
title: "vLLM + Prometheus + Kueue: K8s LLM 서빙 관측가능성 실전 설계"
excerpt: "GPU 활용률과 KV 캐시 압박, 토큰 처리량까지 모니터링하는 LLM 서빙 관측 스택을 Kubernetes 멀티테넌트 환경에 실제로 구성하는 방법을 다룬다."
seo_title: "vLLM Prometheus Kueue LLM 서빙 관측가능성 가이드 - Thaki Cloud"
seo_description: "vLLM /metrics 엔드포인트, DCGM Exporter, Kueue 메트릭을 연동한 K8s LLM 서빙 관측 스택 설계. GPU 활용률과 인퍼런스 비용을 실시간으로 파악한다."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - llmops
tags:
  - observability
  - prometheus
  - vllm
  - kueue
  - gpu-utilization
  - inference-cost
  - grafana
  - kubernetes
  - dcgm
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/llmops/llm-inference-observability-prometheus-kueue/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 10분

LLM 서빙 클러스터를 운영할 때 가장 빠르게 마주치는 문제는 GPU가 비싼데 제대로 쓰이고 있는지 알 수 없다는 점이다. 업계 조사에 따르면 75% 이상의 조직이 피크 부하에서도 GPU를 70% 미만으로 사용하고, 85% 이상 활용하는 곳은 7%에 불과하다. 100 GPU 클러스터에서 활용률을 10%만 높여도 연간 절감액이 수천만 원 규모다.

문제는 일반 REST 서비스 모니터링 방식이 LLM 서빙에 그대로 적용되지 않는다는 것이다. LLM 서빙은 HTTP 요청 수가 아니라 토큰, 컨티뉴어스 배칭, KV 캐시 점유, 드래프트 수락률 같은 지표로 이해해야 한다.

## LLM 서빙 관측의 세 레이어

관측 스택은 세 레이어로 나눠 생각하면 설계가 단순해진다.

**레이어 1: GPU 하드웨어 메트릭**
DCGM(Data Center GPU Manager)이 GPU 활용률, 메모리 사용량, 온도, NVLink 대역폭을 수집한다. `dcgm-exporter`를 DaemonSet으로 배포하면 노드별 GPU 메트릭을 Prometheus로 수집할 수 있다.

**레이어 2: 서빙 프레임워크 메트릭**
vLLM이 `/metrics` 엔드포인트로 노출하는 `vllm:` 프리픽스 메트릭이 여기 속한다. 큐 깊이, KV 캐시 사용률, 생성 토큰 수, 요청별 레이턴시가 이 레이어에서 나온다.

**레이어 3: 워크로드 스케줄링 메트릭**
Kueue가 제공하는 큐별 워크로드 상태, 리소스 쿼터 소진율, 선점 이벤트가 멀티테넌트 환경의 공정성 분석에 쓰인다.

## vLLM 메트릭 상세: 무엇을 봐야 하나

vLLM v0.22 기준 핵심 메트릭은 다음과 같다.

```
# 처리량 & 레이턴시
vllm:generation_tokens_total          # 누적 생성 토큰 수
vllm:prompt_tokens_total              # 누적 프롬프트 토큰 수
vllm:e2e_request_latency_seconds      # 요청 전체 레이턴시 히스토그램
vllm:time_to_first_token_seconds      # TTFT 히스토그램
vllm:time_per_output_token_seconds    # TPOT (처리량 역수)

# 시스템 상태
vllm:num_requests_running             # 현재 실행 중인 요청 수
vllm:num_requests_waiting             # 큐 대기 중인 요청 수
vllm:gpu_cache_usage_perc             # KV 캐시 사용률 (0~1)
vllm:cpu_cache_usage_perc             # CPU 오프로드 캐시 사용률

# 투기적 디코딩 (활성화 시)
vllm:spec_decode_accepted_tokens_total
vllm:spec_decode_draft_tokens_total
```

`vllm:gpu_cache_usage_perc`가 0.9를 넘으면 OOM 위험이 높아진다. 이 값이 지속적으로 높다면 KV 캐시 할당을 늘리거나, 컨텍스트 길이 상한을 조정하거나, GPU를 추가해야 한다.

`vllm:num_requests_waiting`이 지속적으로 0보다 크다면 처리량이 요청 속도를 따라가지 못하는 상태다. 배치 크기 조정이나 GPU 스케일아웃을 검토한다.

## 실전 Prometheus 설정

vLLM Pod에 어노테이션을 추가하면 Prometheus Operator가 자동으로 스크레이프한다.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-llama-70b
spec:
  template:
    metadata:
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8000"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: vllm
        image: vllm/vllm-openai:v0.22.0
        args:
        - "--model"
        - "meta-llama/Llama-3.1-70B-Instruct"
        - "--served-model-name"
        - "llama-70b"
        - "--host"
        - "0.0.0.0"
        - "--port"
        - "8000"
        ports:
        - containerPort: 8000
          name: http
```

ServiceMonitor를 별도로 만드는 방법도 있지만, 어노테이션 방식이 다수 배포 인스턴스를 관리할 때 더 편하다.

## DCGM Exporter 배포

```bash
helm repo add gpu-helm-charts https://nvidia.github.io/dcgm-exporter/helm-charts
helm install dcgm-exporter gpu-helm-charts/dcgm-exporter \
  --namespace monitoring \
  --set serviceMonitor.enabled=true \
  --set serviceMonitor.namespace=monitoring
```

DCGM이 노출하는 메트릭 중 LLM 서빙에서 특히 중요한 것은 아래 두 가지다.

```
DCGM_FI_DEV_GPU_UTIL     # GPU 연산 활용률 (%)
DCGM_FI_DEV_MEM_COPY_UTIL # GPU 메모리 대역폭 활용률 (%)
```

두 값이 모두 낮다면 프로세스가 CPU에서 병목을 맞고 있거나 요청이 없는 것이다. `DCGM_FI_DEV_MEM_COPY_UTIL`이 높고 `DCGM_FI_DEV_GPU_UTIL`이 낮다면 메모리 대역폭 바운드 상태로 모델이 너무 작거나 배치가 지나치게 작다는 신호다.

## Kueue 메트릭 통합

Kueue는 Prometheus 메트릭을 기본으로 노출한다.

```
kueue_pending_workloads           # 큐 대기 워크로드 수 (ClusterQueue별)
kueue_admitted_workloads_total    # 승인된 워크로드 누적 수
kueue_evicted_workloads_total     # 선점된 워크로드 누적 수
kueue_quota_reserved_resources    # 예약된 리소스 (GPU 수 등)
```

멀티테넌트 환경에서 팀별 GPU 사용량을 추적할 때 `kueue_quota_reserved_resources`를 `ClusterQueue` 레이블로 집계하면 팀별 청구 내역을 뽑을 수 있다.

## Grafana 대시보드 핵심 패널

실용적인 LLM 서빙 대시보드는 복잡할 필요가 없다. 다음 패널이 가장 실용적이다.

**패널 1: 토큰 처리량 (요청별)**
```
rate(vllm:generation_tokens_total[5m]) / rate(vllm:num_requests_running[5m])
```
요청당 초당 생성 토큰 수. 모델과 하드웨어 조합의 기준 처리량을 파악하는 데 쓴다.

**패널 2: KV 캐시 포화도**
```
max by (pod) (vllm:gpu_cache_usage_perc)
```
파드별 KV 캐시 최대 사용률. 0.85 이상이면 경보 발령 수준으로 본다.

**패널 3: GPU 활용률 vs 대기 요청 수**
DCGM GPU 활용률과 `vllm:num_requests_waiting`을 같은 그래프에 겹쳐 그린다. GPU가 낮으면서 대기 요청이 없다면 용량이 과다한 상태다. GPU가 높으면서 대기 요청도 많다면 스케일아웃 트리거다.

**패널 4: TTFT p95 (Time to First Token)**
```
histogram_quantile(0.95, rate(vllm:time_to_first_token_seconds_bucket[5m]))
```
사용자 체감 레이턴시의 핵심 지표다. p95가 갑자기 오르면 KV 캐시 포화나 요청 급증이 원인인 경우가 많다.

## 비용 귀속 설계

Kueue의 LocalQueue를 네임스페이스(팀)별로 구성하면 GPU 시간을 팀 단위로 귀속할 수 있다. 아래 PromQL은 팀별 시간당 GPU 사용량을 계산한다.

```promql
sum by (namespace) (
  kueue_quota_reserved_resources{resource="nvidia.com/gpu"}
) * on(namespace) group_left(team) kube_namespace_labels{label_team!=""}
```

이 메트릭에 GPU 시간당 단가를 곱하면 팀별 LLM 서빙 비용을 산출한다. 비용 가시성이 생기면 불필요하게 큰 모델을 요청하거나 리소스를 장기 점유하는 패턴을 팀 스스로 조정하게 된다.

관측 스택을 갖추는 것은 LLM 서빙 최적화의 전제 조건이다. 무엇이 느린지, 어디서 GPU가 낭비되는지 데이터 없이는 개선 방향을 잡기 어렵다. vLLM 메트릭 + DCGM + Kueue 조합은 K8s 기반 LLM 플랫폼에서 그 데이터를 얻는 가장 현실적인 경로다.
