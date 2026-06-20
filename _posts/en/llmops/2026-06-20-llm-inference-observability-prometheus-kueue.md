---
title: "vLLM + Prometheus + Kueue: Building an LLM Serving Observability Stack on Kubernetes"
excerpt: "How to build an LLM serving observability stack that monitors GPU utilization, KV cache pressure, and token throughput in a Kubernetes multi-tenant environment."
seo_title: "vLLM Prometheus Kueue LLM Serving Observability Guide - Thaki Cloud"
seo_description: "Design for a K8s LLM serving observability stack integrating vLLM /metrics, DCGM Exporter, and Kueue metrics. Track GPU utilization and inference costs in real time."
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
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/llmops/llm-inference-observability-prometheus-kueue/"
reading_time: true
lang: en
---

⏱️ **Estimated reading time**: 10 min

The most immediate problem when operating an LLM serving cluster is not knowing whether expensive GPUs are actually being used. Industry surveys show more than 75% of organizations run below 70% GPU utilization even at peak load, and only 7% sustain above 85%. Raising utilization by 10% on a 100-GPU cluster saves tens of thousands of dollars annually.

The underlying issue is that standard REST service monitoring does not translate directly to LLM serving. LLM serving must be understood through tokens, continuous batching, KV cache occupancy, and draft acceptance rate, not HTTP request counts.

## Three Layers of LLM Serving Observability

Thinking in three layers simplifies the design.

**Layer 1: GPU Hardware Metrics**
DCGM (Data Center GPU Manager) collects GPU utilization, memory usage, temperature, and NVLink bandwidth. Deploying `dcgm-exporter` as a DaemonSet feeds per-node GPU metrics into Prometheus.

**Layer 2: Serving Framework Metrics**
vLLM exposes `vllm:` prefixed metrics at the `/metrics` endpoint. Queue depth, KV cache utilization, generated token counts, and per-request latency come from this layer.

**Layer 3: Workload Scheduling Metrics**
Kueue provides per-queue workload status, resource quota exhaustion rates, and preemption events for fairness analysis in multi-tenant environments.

## vLLM Metrics in Detail: What to Watch

Key metrics as of vLLM v0.22:

```
# throughput and latency
vllm:generation_tokens_total          # cumulative generated tokens
vllm:prompt_tokens_total              # cumulative prompt tokens
vllm:e2e_request_latency_seconds      # full request latency histogram
vllm:time_to_first_token_seconds      # TTFT histogram
vllm:time_per_output_token_seconds    # TPOT (inverse of throughput)

# system state
vllm:num_requests_running             # requests currently executing
vllm:num_requests_waiting             # requests waiting in queue
vllm:gpu_cache_usage_perc             # KV cache utilization (0-1)
vllm:cpu_cache_usage_perc             # CPU offload cache utilization

# speculative decoding (when enabled)
vllm:spec_decode_accepted_tokens_total
vllm:spec_decode_draft_tokens_total
```

When `vllm:gpu_cache_usage_perc` exceeds 0.9, OOM risk increases significantly. If this value stays persistently high, increase KV cache allocation, reduce the context length ceiling, or add GPUs.

When `vllm:num_requests_waiting` stays consistently above 0, throughput is not keeping up with request rate. Adjust batch size or scale out GPUs.

## Prometheus Configuration

Adding annotations to the vLLM Pod lets Prometheus Operator scrape it automatically:

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

A separate ServiceMonitor works as well, but the annotation approach is easier to manage when running many deployment instances.

## Deploying DCGM Exporter

```bash
helm repo add gpu-helm-charts https://nvidia.github.io/dcgm-exporter/helm-charts
helm install dcgm-exporter gpu-helm-charts/dcgm-exporter \
  --namespace monitoring \
  --set serviceMonitor.enabled=true \
  --set serviceMonitor.namespace=monitoring
```

The two DCGM metrics most critical for LLM serving:

```
DCGM_FI_DEV_GPU_UTIL     # GPU compute utilization (%)
DCGM_FI_DEV_MEM_COPY_UTIL # GPU memory bandwidth utilization (%)
```

If both are low, either the process is bottlenecked on CPU or there are no incoming requests. If `DCGM_FI_DEV_MEM_COPY_UTIL` is high while `DCGM_FI_DEV_GPU_UTIL` is low, the workload is memory-bandwidth bound: the model is too small or batch size is too small.

## Kueue Metrics Integration

Kueue exposes Prometheus metrics by default:

```
kueue_pending_workloads           # pending workloads per ClusterQueue
kueue_admitted_workloads_total    # cumulative admitted workloads
kueue_evicted_workloads_total     # cumulative evicted workloads
kueue_quota_reserved_resources    # reserved resources (GPU count, etc.)
```

In multi-tenant environments, aggregating `kueue_quota_reserved_resources` by the `ClusterQueue` label produces per-team billing data.

## Core Grafana Dashboard Panels

A practical LLM serving dashboard does not need to be complex. These panels deliver the most value:

**Panel 1: Token throughput per request**
```
rate(vllm:generation_tokens_total[5m]) / rate(vllm:num_requests_running[5m])
```
Generated tokens per second per request. Use this to establish baseline throughput for a given model-hardware combination.

**Panel 2: KV cache saturation**
```
max by (pod) (vllm:gpu_cache_usage_perc)
```
Maximum KV cache utilization per Pod. Treat 0.85 as the alert threshold.

**Panel 3: GPU utilization vs waiting requests**
Overlay DCGM GPU utilization and `vllm:num_requests_waiting` on the same graph. Low GPU with no waiting requests means excess capacity. High GPU with many waiting requests is the scale-out trigger.

**Panel 4: TTFT p95**
```
histogram_quantile(0.95, rate(vllm:time_to_first_token_seconds_bucket[5m]))
```
The core metric for user-perceived latency. A sudden rise in p95 is most often caused by KV cache saturation or a request spike.

## Cost Attribution Design

Configuring Kueue LocalQueues per namespace (team) enables per-team GPU time attribution. The PromQL below calculates hourly GPU usage per team:

```promql
sum by (namespace) (
  kueue_quota_reserved_resources{resource="nvidia.com/gpu"}
) * on(namespace) group_left(team) kube_namespace_labels{label_team!=""}
```

Multiplying this metric by the per-GPU-hour rate produces per-team LLM serving costs. Once cost visibility exists, teams naturally self-correct patterns like requesting unnecessarily large models or holding resources for extended periods.

Building the observability stack is a prerequisite for LLM serving optimization. Without data on what is slow and where GPU cycles are being wasted, there is no basis for improvement decisions. The vLLM metrics plus DCGM plus Kueue combination is the most practical path to that data on a K8s-based LLM platform.
