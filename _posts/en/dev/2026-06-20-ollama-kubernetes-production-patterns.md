---
title: "Running Ollama on Kubernetes in Production"
excerpt: "Practical patterns for operating Ollama as an LLM serving layer in a K8s cluster rather than as a local experimentation tool."
seo_title: "Ollama Kubernetes Production Deployment Patterns GPU PVC HPA - Thaki Cloud"
seo_description: "GPU node configuration, model storage PVC design, HPA autoscaling, Prometheus monitoring, and Modelfile patterns for deploying Ollama on Kubernetes."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - dev
tags: [ollama, kubernetes, llm-serving, gpu, self-hosting, modelfile, prometheus, hpa]
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/dev/ollama-kubernetes-production-patterns/"
reading_time: true
lang: en
---

⏱️ **Estimated reading time**: 9 min

Ollama recorded 52 million downloads in Q1 2026. It has moved well beyond a personal experimentation tool and is being used as team-level infrastructure. Running `ollama run` on a local Mac and operating a serving layer for an entire team on a Kubernetes cluster are architecturally different problems. This post covers the latter.

## Why Ollama: Positioning Against vLLM

vLLM focuses on throughput optimization. PagedAttention, continuous batching, and FP8 inference are all about squeezing maximum throughput from GPU resources. Ollama's strength is simplicity of installation and model management. `ollama pull llama3:70b` downloads the model in one line and an OpenAI-compatible API server comes up automatically.

The two tools occupy different layers rather than competing directly. vLLM fits a public inference endpoint where throughput matters. Ollama fits an internal code-assist tool or a small private chatbot used by a development team, where operational simplicity outweighs raw throughput.

## Basic Kubernetes Deployment

### Namespace and RBAC

```bash
kubectl create namespace ollama
kubectl label namespace ollama kueue.x-k8s.io/team=internal-tools
```

### GPU PersistentVolumeClaim

Model files range from tens of GB to hundreds of GB. Without a PVC, every Pod restart triggers a full model re-download. That is an operational disaster.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ollama-models
  namespace: ollama
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: nfs-retain    # use the StorageClass appropriate for your cluster
  resources:
    requests:
      storage: 500Gi
```

If multiple Pods need to share the same model volume, you need a StorageClass that supports `ReadWriteMany` (NFS, CephFS, Azure Files, etc.). With `ReadWriteOnce`, the volume attaches to only one Pod at a time.

### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama
  namespace: ollama
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ollama
  template:
    metadata:
      labels:
        app: ollama
    spec:
      tolerations:
      - key: nvidia.com/gpu
        operator: Equal
        value: present
        effect: NoSchedule
      containers:
      - name: ollama
        image: ollama/ollama:latest
        ports:
        - containerPort: 11434
        env:
        - name: OLLAMA_MODELS
          value: "/models"
        - name: OLLAMA_NUM_PARALLEL
          value: "4"         # number of concurrent requests to process
        - name: OLLAMA_MAX_LOADED_MODELS
          value: "2"         # maximum number of models to keep in memory
        volumeMounts:
        - name: models
          mountPath: /models
        resources:
          limits:
            nvidia.com/gpu: "1"
            memory: "32Gi"
          requests:
            nvidia.com/gpu: "1"
            memory: "16Gi"
      volumes:
      - name: models
        persistentVolumeClaim:
          claimName: ollama-models
```

`OLLAMA_NUM_PARALLEL` caps the number of requests processed concurrently. When GPU memory is insufficient to hold multiple requests in flight, they must be serialized. Leaving the default (1) means requests queue up serially and latency grows.

### Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ollama
  namespace: ollama
spec:
  selector:
    app: ollama
  ports:
  - port: 11434
    targetPort: 11434
  type: ClusterIP
```

For access from outside the cluster, expose via Ingress or LoadBalancer. Because Ollama has no built-in authentication, always place an auth proxy in front of any external exposure.

## Custom Model Configuration with Modelfile

An Ollama Modelfile builds a custom model from a base model, with a fixed system prompt, parameters, and context length.

```dockerfile
FROM llama3:8b

SYSTEM """
You are ThakiCloud's internal code review assistant.
You specialize in Go, Kubernetes YAML, and Python code.
Review in order: security vulnerabilities, performance issues, code style.
"""

PARAMETER temperature 0.1      # low temperature is better for code review
PARAMETER num_ctx 8192          # enough context to handle long files
PARAMETER num_predict 2048
```

Two approaches for building and deploying a Modelfile:

**Option 1: Preload with an InitContainer**

```yaml
initContainers:
- name: model-puller
  image: ollama/ollama:latest
  command:
  - sh
  - -c
  - |
    ollama serve &
    sleep 5
    ollama pull llama3:8b
    # mount Modelfile from ConfigMap, then build
    ollama create code-reviewer -f /modelfiles/Modelfile
    kill %1
  volumeMounts:
  - name: models
    mountPath: /models
  - name: modelfiles
    mountPath: /modelfiles
```

**Option 2: Run as a Separate Job**

Run a separate Job after the Pod is up to pull the model and build the Modelfile. Run it once on initial deployment.

## Structured Output

Ollama enforces JSON output via the `format` parameter:

```bash
curl http://ollama:11434/api/generate -d '{
  "model": "llama3:8b",
  "prompt": "Find security vulnerabilities in the following code and return them as JSON:",
  "format": "json",
  "stream": false
}'
```

You can also pin the output format via the system prompt in the Modelfile:

```dockerfile
SYSTEM """
Always return responses in the following JSON schema:
{"issues": [{"severity": "high|medium|low", "line": number, "description": string}]}
Include no text outside the JSON structure.
"""
```

In practice, even with `format: "json"` enabled, the model does not always respect the schema fully. A validation layer that parses and checks the schema after each response is necessary.

## Prometheus Monitoring

Ollama exposes Prometheus metrics at the `/metrics` endpoint:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: ollama
  namespace: ollama
spec:
  selector:
    matchLabels:
      app: ollama
  endpoints:
  - port: http
    path: /metrics
    interval: 30s
```

Key metrics:

```promql
# number of requests currently being processed
ollama_request_duration_seconds_count

# average processing time
rate(ollama_request_duration_seconds_sum[5m])
/ rate(ollama_request_duration_seconds_count[5m])

# number of loaded models
ollama_loaded_model_count
```

## HPA Autoscaling

GPU-based HPA scales on GPU utilization metrics. Collecting GPU utilization from NVIDIA's DCGM Exporter into Prometheus makes it available as a custom HPA metric.

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ollama
  namespace: ollama
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ollama
  minReplicas: 1
  maxReplicas: 4
  metrics:
  - type: Pods
    pods:
      metric:
        name: ollama_queue_depth    # queued request count (custom metric)
      target:
        type: AverageValue
        averageValue: "10"
```

When GPU nodes are insufficient, HPA scale-out attempts leave Pods in Pending state. Node-level scaling requires Cluster Autoscaler or Karpenter in addition to HPA.

## Authentication Proxy Pattern

Ollama has no built-in authentication. Even on an internal service, leaving it open means anyone can use the model. The simplest approach is OAuth2 Proxy or Nginx validating an API key.

```yaml
# Nginx ConfigMap example
nginx.conf: |
  location / {
    if ($http_x_api_key != "your-team-key") {
      return 401;
    }
    proxy_pass http://ollama:11434;
  }
```

Integrating with an IdP such as Keycloak allows per-team access control.

## Operational Tips

**Schedule model updates as a separate Job.** `ollama pull` can run alongside a live Pod, but capacity issues during updates sometimes cause Pod restarts. Running the update as a Job during a maintenance window is safer.

**Tune `OLLAMA_MAX_LOADED_MODELS` to match GPU memory.** Two 70B models loaded simultaneously will exhaust VRAM. Calculate the model size relative to available VRAM and set this value accordingly.

**Adjust the log level.** By default, Ollama logs detailed output for every request. Set `OLLAMA_DEBUG=false` to reduce log volume in production.

## Summary

Running Ollama properly on Kubernetes requires four things: a model PVC, GPU tolerations, an auth proxy, and monitoring. Using Modelfile to configure team-specific models puts the system prompt and parameters under version control. For internal tool serving where operational simplicity matters more than throughput, Ollama is a good choice relative to its setup cost.
