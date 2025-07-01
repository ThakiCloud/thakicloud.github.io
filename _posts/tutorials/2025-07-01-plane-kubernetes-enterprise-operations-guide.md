---
title: "Plane 엔터프라이즈 쿠버네티스 운영 가이드 - Helm부터 자체 클라우드까지"
excerpt: "Plane 쿠버네티스 운영의 모든 것을 다루는 완전한 엔터프라이즈 가이드. Helm 차트, AWS/GCP/자체 클라우드 배포, 규모별 하드웨어 스펙, 모니터링, CI/CD까지 실전 운영 노하우를 모두 담았습니다."
seo_title: "Plane 엔터프라이즈 쿠버네티스 운영 가이드 - Helm 자체클라우드 - Thaki Cloud"
seo_description: "Plane 엔터프라이즈 쿠버네티스 완전 운영 가이드. Helm 차트 AWS EKS GCP GKE 자체클라우드 구축 규모별 하드웨어 스펙 모니터링 CI/CD 백업 보안"
date: 2025-07-01
last_modified_at: 2025-07-01
categories:
  - tutorials
tags:
  - plane
  - kubernetes
  - enterprise
  - helm
  - aws-eks
  - gcp-gke
  - private-cloud
  - self-hosted
  - monitoring
  - prometheus
  - grafana
  - cicd
  - gitops
  - argocd
  - backup
  - security
  - hardware-specs
  - production
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
header:
  teaser: "/assets/images/thumbnails/post-thumbnail.jpg"
  overlay_image: "/assets/images/headers/post-header.jpg"
  overlay_filter: 0.5
canonical_url: "https://thakicloud.github.io/tutorials/plane-kubernetes-enterprise-operations-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 30분

## 서론

[이전 글](#)에서 OrbStack 개발 환경과 기본 쿠버네티스 배포를 다뤘다면, 이번에는 **실제 엔터프라이즈 운영**에 필요한 모든 것을 다루겠습니다.

이 가이드는 **진짜 현업에서 사용할 수 있는** 완전한 운영 매뉴얼입니다:

- 📦 **Helm 차트 마스터**: 재사용 가능한 배포 패키지 완전 정복
- ☁️ **멀티 클라우드 전략**: AWS, GCP, 자체 클라우드 모든 환경 커버
- 🏗️ **자체 클라우드 구축**: 하드웨어부터 k8s 클러스터까지 A-Z
- 📏 **규모별 스펙 가이드**: 10명~10,000명 팀까지 최적화된 구성
- 📊 **완전한 모니터링**: Prometheus, Grafana, 알림 시스템
- 🔒 **엔터프라이즈 보안**: RBAC, 네트워크 정책, 컴플라이언스
- 🚀 **GitOps CI/CD**: ArgoCD로 완전 자동화된 배포 파이프라인

## Helm 차트 완전 정복

### 1. Plane Helm 차트 구조

```bash
# Helm 차트 디렉토리 구조
plane-helm/
├── Chart.yaml                 # 차트 메타데이터
├── values.yaml               # 기본 설정값
├── values-dev.yaml           # 개발 환경 설정
├── values-staging.yaml       # 스테이징 환경 설정  
├── values-production.yaml    # 운영 환경 설정
├── templates/
│   ├── _helpers.tpl         # 헬퍼 템플릿
│   ├── configmap.yaml       # ConfigMap 템플릿
│   ├── secret.yaml          # Secret 템플릿
│   ├── pvc.yaml             # PersistentVolumeClaim
│   ├── postgresql/
│   │   ├── statefulset.yaml
│   │   ├── service.yaml
│   │   └── init-job.yaml
│   ├── redis/
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   ├── minio/
│   │   ├── statefulset.yaml
│   │   ├── service.yaml
│   │   └── init-job.yaml
│   ├── api/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── hpa.yaml
│   ├── worker/
│   │   ├── deployment.yaml
│   │   └── hpa.yaml
│   ├── web/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── hpa.yaml
│   ├── admin/
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   ├── ingress.yaml
│   ├── servicemonitor.yaml  # Prometheus 모니터링
│   └── networkpolicy.yaml   # 네트워크 정책
└── charts/                   # 서브차트 (선택사항)
```

### 2. Chart.yaml 구성

```yaml
# Chart.yaml
apiVersion: v2
name: plane
description: Open-source project management platform
type: application
version: 1.0.0
appVersion: "preview"
home: https://plane.so
sources:
  - https://github.com/makeplane/plane
maintainers:
  - name: Plane Team
    email: support@plane.so
keywords:
  - project-management
  - issue-tracking
  - agile
  - scrum
annotations:
  category: Productivity
dependencies:
  - name: postgresql
    version: "12.x.x"
    repository: "https://charts.bitnami.com/bitnami"
    condition: postgresql.enabled
  - name: redis
    version: "18.x.x" 
    repository: "https://charts.bitnami.com/bitnami"
    condition: redis.enabled
  - name: minio
    version: "12.x.x"
    repository: "https://charts.bitnami.com/bitnami"
    condition: minio.enabled
```

### 3. 메인 values.yaml

```yaml
# values.yaml
global:
  # 이미지 설정
  imageRegistry: ""
  imagePullSecrets: []
  storageClass: ""
  
# Plane 애플리케이션 설정
plane:
  # 환경 설정
  environment: production
  debug: false
  domain: "plane.yourdomain.com"
  
  # 시크릿 설정 (외부에서 주입)
  secrets:
    secretKey: ""
    postgresPassword: ""
    githubClientSecret: ""
    slackWebhookUrl: ""
  
  # 이미지 설정
  image:
    registry: docker.io
    repository: makeplane/plane
    tag: "latest"
    pullPolicy: IfNotPresent
  
# API 서버 설정
api:
  enabled: true
  replicaCount: 3
  
  image:
    repository: makeplane/plane-backend
    tag: "latest"
    
  resources:
    requests:
      memory: "512Mi"
      cpu: "200m"
    limits:
      memory: "1Gi"
      cpu: "500m"
      
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10
    targetCPUUtilizationPercentage: 70
    targetMemoryUtilizationPercentage: 80
  
  service:
    type: ClusterIP
    port: 8000
    
  # 헬스체크 설정
  livenessProbe:
    httpGet:
      path: /api/health/
      port: 8000
    initialDelaySeconds: 60
    periodSeconds: 30
    timeoutSeconds: 10
    
  readinessProbe:
    httpGet:
      path: /api/health/
      port: 8000
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 5

# Worker 설정
worker:
  enabled: true
  replicaCount: 2
  
  image:
    repository: makeplane/plane-backend
    tag: "latest"
    
  resources:
    requests:
      memory: "256Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "200m"
      
  autoscaling:
    enabled: true
    minReplicas: 1
    maxReplicas: 5
    targetCPUUtilizationPercentage: 80

# Beat 스케줄러 설정
beat:
  enabled: true
  replicaCount: 1
  
  resources:
    requests:
      memory: "128Mi"
      cpu: "50m"
    limits:
      memory: "256Mi"
      cpu: "100m"

# Web 애플리케이션 설정
web:
  enabled: true
  replicaCount: 2
  
  image:
    repository: makeplane/plane-frontend
    tag: "latest"
    
  resources:
    requests:
      memory: "256Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "200m"
      
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 8
    targetCPUUtilizationPercentage: 70
  
  service:
    type: ClusterIP
    port: 3000

# Admin 패널 설정
admin:
  enabled: true
  replicaCount: 1
  
  image:
    repository: makeplane/plane-admin
    tag: "latest"
    
  resources:
    requests:
      memory: "128Mi"
      cpu: "50m"
    limits:
      memory: "256Mi"
      cpu: "100m"
  
  service:
    type: ClusterIP
    port: 3001

# PostgreSQL 설정
postgresql:
  enabled: true
  auth:
    postgresPassword: ""
    username: "plane"
    password: ""
    database: "plane"
  
  primary:
    persistence:
      enabled: true
      size: 20Gi
      storageClass: ""
    
    resources:
      requests:
        memory: "512Mi"
        cpu: "250m"
      limits:
        memory: "1Gi"
        cpu: "500m"
        
    configuration: |-
      max_connections = 200
      shared_buffers = 256MB
      effective_cache_size = 1GB
      maintenance_work_mem = 64MB
      checkpoint_completion_target = 0.9
      wal_buffers = 16MB
      default_statistics_target = 100
      random_page_cost = 1.1
      effective_io_concurrency = 200

# Redis 설정
redis:
  enabled: true
  auth:
    enabled: false
    
  master:
    persistence:
      enabled: true
      size: 5Gi
      
    resources:
      requests:
        memory: "128Mi"
        cpu: "100m"
      limits:
        memory: "256Mi"
        cpu: "200m"
        
    configuration: |-
      maxmemory 256mb
      maxmemory-policy allkeys-lru
      appendonly yes

# MinIO 설정
minio:
  enabled: true
  auth:
    rootUser: "plane"
    rootPassword: "plane123"
    
  persistence:
    enabled: true
    size: 50Gi
    
  resources:
    requests:
      memory: "256Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "200m"

# Ingress 설정
ingress:
  enabled: true
  className: "nginx"
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "50m"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "300"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "300"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/configuration-snippet: |
      more_set_headers "X-Frame-Options: SAMEORIGIN";
      more_set_headers "X-Content-Type-Options: nosniff";
      more_set_headers "X-XSS-Protection: 1; mode=block";
      more_set_headers "Referrer-Policy: strict-origin-when-cross-origin";
  
  tls:
    enabled: true
    secretName: "plane-tls"
  
  hosts:
    - host: "plane.yourdomain.com"
      paths:
        - path: "/api"
          pathType: "Prefix"
          service: "api"
        - path: "/admin"
          pathType: "Prefix"
          service: "admin"
        - path: "/uploads"
          pathType: "Prefix"
          service: "minio"
        - path: "/"
          pathType: "Prefix"
          service: "web"

# 네트워크 정책
networkPolicy:
  enabled: true
  
# 서비스 모니터 (Prometheus)
serviceMonitor:
  enabled: true
  namespace: ""
  interval: 30s
  scrapeTimeout: 10s

# Pod Disruption Budget
podDisruptionBudget:
  enabled: true
  minAvailable: 1

# Security Context
securityContext:
  enabled: true
  runAsNonRoot: true
  runAsUser: 1001
  fsGroup: 1001

# 노드 선택 및 톨러레이션
nodeSelector: {}
tolerations: []
affinity: {}

# 추가 라벨 및 어노테이션
commonLabels: {}
commonAnnotations: {}
```

### 4. 환경별 values 파일

#### 개발 환경 (values-dev.yaml)

```yaml
# values-dev.yaml
plane:
  environment: development
  debug: true
  domain: "plane-dev.yourdomain.com"

# 개발 환경은 리소스를 최소화
api:
  replicaCount: 1
  autoscaling:
    enabled: false
  resources:
    requests:
      memory: "256Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "250m"

worker:
  replicaCount: 1
  autoscaling:
    enabled: false

web:
  replicaCount: 1
  autoscaling:
    enabled: false

# 외부 서비스 비활성화 (개발용 내장 서비스 사용)
postgresql:
  enabled: true
  primary:
    persistence:
      size: 5Gi

redis:
  enabled: true
  master:
    persistence:
      size: 1Gi

minio:
  enabled: true
  persistence:
    size: 10Gi

# SSL 비활성화
ingress:
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
  tls:
    enabled: false
```

#### 스테이징 환경 (values-staging.yaml)

```yaml
# values-staging.yaml
plane:
  environment: staging
  debug: false
  domain: "plane-staging.yourdomain.com"

# 운영과 유사하지만 규모 축소
api:
  replicaCount: 2
  autoscaling:
    minReplicas: 1
    maxReplicas: 4

worker:
  replicaCount: 1
  autoscaling:
    minReplicas: 1
    maxReplicas: 3

web:
  replicaCount: 2
  autoscaling:
    minReplicas: 1
    maxReplicas: 4

# 스테이징용 인증서 발급자
ingress:
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-staging"
```

#### 운영 환경 (values-production.yaml)

```yaml
# values-production.yaml
plane:
  environment: production
  debug: false
  domain: "plane.yourdomain.com"

# 고가용성 설정
api:
  replicaCount: 3
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 15
    targetCPUUtilizationPercentage: 60  # 더 보수적

worker:
  replicaCount: 3
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10

web:
  replicaCount: 3
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 12

# 외부 관리형 서비스 사용
postgresql:
  enabled: false  # AWS RDS 또는 Google Cloud SQL 사용
  
redis:
  enabled: false  # AWS ElastiCache 또는 Google Cloud Memorystore 사용
  
minio:
  enabled: false  # AWS S3 또는 Google Cloud Storage 사용

# 운영 환경 보안 강화
securityContext:
  enabled: true
  runAsNonRoot: true
  runAsUser: 1001
  fsGroup: 1001
  capabilities:
    drop: ["ALL"]
  readOnlyRootFilesystem: true

# Pod Anti-Affinity 설정 (고가용성)
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values: ["plane"]
        topologyKey: kubernetes.io/hostname

# 리소스 할당량 증가
api:
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
    limits:
      memory: "2Gi"
      cpu: "1000m"

# 모니터링 활성화
serviceMonitor:
  enabled: true
  interval: 15s

# 네트워크 정책 활성화
networkPolicy:
  enabled: true

# PDB 설정
podDisruptionBudget:
  enabled: true
  minAvailable: 2
```

### 5. 헬퍼 템플릿 (_helpers.tpl)

{% raw %}
```yaml
{{/*
Expand the name of the chart.
*/}}
{{- define "plane.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "plane.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "plane.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "plane.labels" -}}
helm.sh/chart: {{ include "plane.chart" . }}
{{ include "plane.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "plane.selectorLabels" -}}
app.kubernetes.io/name: {{ include "plane.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "plane.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "plane.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate the PostgreSQL connection URL
*/}}
{{- define "plane.postgresqlUrl" -}}
{{- if .Values.postgresql.enabled }}
postgres://{{ .Values.postgresql.auth.username }}:{{ .Values.postgresql.auth.password }}@{{ include "plane.fullname" . }}-postgresql:5432/{{ .Values.postgresql.auth.database }}
{{- else }}
{{- .Values.externalDatabase.url }}
{{- end }}
{{- end }}

{{/*
Generate the Redis URL
*/}}
{{- define "plane.redisUrl" -}}
{{- if .Values.redis.enabled }}
redis://{{ include "plane.fullname" . }}-redis-master:6379
{{- else }}
{{- .Values.externalRedis.url }}
{{- end }}
{{- end }}

{{/*
Generate MinIO endpoint
*/}}
{{- define "plane.minioEndpoint" -}}
{{- if .Values.minio.enabled }}
http://{{ include "plane.fullname" . }}-minio:9000
{{- else }}
{{- .Values.externalStorage.endpoint }}
{{- end }}
{{- end }}

{{/*
Image pull secrets
*/}}
{{- define "plane.imagePullSecrets" -}}
{{- if or .Values.global.imagePullSecrets .Values.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- range .Values.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}
{{- end }}
```
{% endraw %}

### 6. API Deployment 템플릿

{% raw %}
```yaml
# templates/api/deployment.yaml
{{- if .Values.api.enabled }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "plane.fullname" . }}-api
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "plane.labels" . | nindent 4 }}
    app.kubernetes.io/component: api
spec:
  {{- if not .Values.api.autoscaling.enabled }}
  replicas: {{ .Values.api.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "plane.selectorLabels" . | nindent 6 }}
      app.kubernetes.io/component: api
  template:
    metadata:
      labels:
        {{- include "plane.selectorLabels" . | nindent 8 }}
        app.kubernetes.io/component: api
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
        checksum/secret: {{ include (print $.Template.BasePath "/secret.yaml") . | sha256sum }}
    spec:
      {{- include "plane.imagePullSecrets" . | nindent 6 }}
      {{- if .Values.securityContext.enabled }}
      securityContext:
        runAsNonRoot: {{ .Values.securityContext.runAsNonRoot }}
        runAsUser: {{ .Values.securityContext.runAsUser }}
        fsGroup: {{ .Values.securityContext.fsGroup }}
      {{- end }}
      initContainers:
      - name: wait-for-db
        image: busybox:1.35
        command: ['sh', '-c']
        args:
          - |
            {{- if .Values.postgresql.enabled }}
            until nc -z {{ include "plane.fullname" . }}-postgresql 5432; do
              echo "Waiting for PostgreSQL..."
              sleep 2
            done
            {{- end }}
            {{- if .Values.redis.enabled }}
            until nc -z {{ include "plane.fullname" . }}-redis-master 6379; do
              echo "Waiting for Redis..."
              sleep 2
            done
            {{- end }}
            echo "Dependencies are ready!"
      containers:
      - name: api
        image: "{{ .Values.api.image.repository }}:{{ .Values.api.image.tag | default .Chart.AppVersion }}"
        imagePullPolicy: {{ .Values.api.image.pullPolicy }}
        ports:
        - name: http
          containerPort: 8000
          protocol: TCP
        env:
        - name: DATABASE_URL
          value: {{ include "plane.postgresqlUrl" . | quote }}
        - name: REDIS_URL
          value: {{ include "plane.redisUrl" . | quote }}
        - name: MINIO_ENDPOINT
          value: {{ include "plane.minioEndpoint" . | quote }}
        envFrom:
        - configMapRef:
            name: {{ include "plane.fullname" . }}-config
        - secretRef:
            name: {{ include "plane.fullname" . }}-secret
        {{- if .Values.api.livenessProbe }}
        livenessProbe:
          {{- toYaml .Values.api.livenessProbe | nindent 10 }}
        {{- end }}
        {{- if .Values.api.readinessProbe }}
        readinessProbe:
          {{- toYaml .Values.api.readinessProbe | nindent 10 }}
        {{- end }}
        resources:
          {{- toYaml .Values.api.resources | nindent 10 }}
        {{- if .Values.securityContext.enabled }}
        securityContext:
          capabilities:
            drop: {{ .Values.securityContext.capabilities.drop }}
          readOnlyRootFilesystem: {{ .Values.securityContext.readOnlyRootFilesystem }}
        {{- end }}
        volumeMounts:
        - name: static-files
          mountPath: /app/static
        - name: tmp
          mountPath: /tmp
      volumes:
      - name: static-files
        emptyDir: {}
      - name: tmp
        emptyDir: {}
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
{{- end }}
```
{% endraw %}

### 7. HPA 템플릿

{% raw %}
```yaml
# templates/api/hpa.yaml
{{- if and .Values.api.enabled .Values.api.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "plane.fullname" . }}-api
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "plane.labels" . | nindent 4 }}
    app.kubernetes.io/component: api
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "plane.fullname" . }}-api
  minReplicas: {{ .Values.api.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.api.autoscaling.maxReplicas }}
  metrics:
  {{- if .Values.api.autoscaling.targetCPUUtilizationPercentage }}
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: {{ .Values.api.autoscaling.targetCPUUtilizationPercentage }}
  {{- end }}
  {{- if .Values.api.autoscaling.targetMemoryUtilizationPercentage }}
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: {{ .Values.api.autoscaling.targetMemoryUtilizationPercentage }}
  {{- end }}
{{- end }}
```
{% endraw %}

### 8. Helm 차트 배포 스크립트

```bash
#!/bin/bash
# deploy-with-helm.sh

set -e

# 설정 변수
NAMESPACE="plane"
RELEASE_NAME="plane"
CHART_PATH="./plane-helm"
ENVIRONMENT=${1:-development}

echo "🎯 Plane Helm 배포 시작 (환경: $ENVIRONMENT)"

# Helm 저장소 업데이트
echo "📦 Helm 저장소 업데이트 중..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# 네임스페이스 생성
echo "🏗️ 네임스페이스 생성 중..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# 의존성 업데이트
echo "🔄 차트 의존성 업데이트 중..."
helm dependency update $CHART_PATH

# Secret 생성 (외부에서 주입)
echo "🔐 Secret 생성 중..."
kubectl create secret generic plane-secrets \
  --from-literal=secretKey="$(openssl rand -hex 32)" \
  --from-literal=postgresPassword="$(openssl rand -hex 16)" \
  --from-literal=githubClientSecret="your_github_client_secret" \
  --from-literal=slackWebhookUrl="your_slack_webhook_url" \
  --namespace=$NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

# 환경별 배포
case $ENVIRONMENT in
  development)
    VALUES_FILE="values-dev.yaml"
    ;;
  staging)
    VALUES_FILE="values-staging.yaml"
    ;;
  production)
    VALUES_FILE="values-production.yaml"
    ;;
  *)
    VALUES_FILE="values.yaml"
    ;;
esac

echo "📋 사용할 Values 파일: $VALUES_FILE"

# Helm 배포
echo "🚀 Helm 차트 배포 중..."
helm upgrade --install $RELEASE_NAME $CHART_PATH \
  --namespace=$NAMESPACE \
  --values=$CHART_PATH/$VALUES_FILE \
  --set plane.secrets.secretKey="" \
  --set plane.secrets.postgresPassword="" \
  --timeout=10m \
  --wait

echo "✅ 배포 완료!"

# 배포 상태 확인
echo "📊 배포 상태 확인:"
helm status $RELEASE_NAME -n $NAMESPACE
kubectl get pods -n $NAMESPACE

# 접근 정보 출력
echo ""
echo "🌐 접근 정보:"
INGRESS_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
if [ "$INGRESS_IP" != "pending" ] && [ -n "$INGRESS_IP" ]; then
    echo "   웹 URL: http://$INGRESS_IP"
else
    echo "   포트 포워딩: kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME-web 3000:3000"
fi

# 로그 확인 방법
echo ""
echo "🔍 로그 확인:"
echo "   kubectl logs -f deployment/$RELEASE_NAME-api -n $NAMESPACE"
echo "   kubectl logs -f deployment/$RELEASE_NAME-web -n $NAMESPACE"

 # 문제 해결
echo ""
echo "🔧 문제 해결:"
echo "   helm uninstall $RELEASE_NAME -n $NAMESPACE  # 제거"
echo "   helm rollback $RELEASE_NAME 1 -n $NAMESPACE  # 롤백"
```

## 멀티 클라우드 배포 전략

### 1. AWS EKS 배포

#### EKS 클러스터 생성

```bash
#!/bin/bash
# setup-eks-cluster.sh

set -e

# 설정 변수
CLUSTER_NAME="plane-production"
REGION="ap-northeast-2"  # 서울 리전
NODE_GROUP_NAME="plane-workers"
KUBERNETES_VERSION="1.28"

echo "🌩️ AWS EKS 클러스터 생성 시작"

# EKS 클러스터 생성
echo "🏗️ EKS 클러스터 생성 중..."
eksctl create cluster \
  --name $CLUSTER_NAME \
  --version $KUBERNETES_VERSION \
  --region $REGION \
  --zones ap-northeast-2a,ap-northeast-2b,ap-northeast-2c \
  --nodegroup-name $NODE_GROUP_NAME \
  --node-type m5.large \
  --nodes 3 \
  --nodes-min 2 \
  --nodes-max 10 \
  --managed \
  --enable-ssm \
  --alb-ingress-access \
  --full-ecr-access \
  --asg-access \
  --external-dns-access \
  --appmesh-access \
  --appmesh-preview-access

# kubectl 설정
echo "⚙️ kubectl 설정 중..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# 필수 애드온 설치
echo "🔧 EKS 애드온 설치 중..."

# AWS Load Balancer Controller
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"

# cert-manager 설치
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Cluster Autoscaler 설치
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

echo "✅ EKS 클러스터 생성 완료!"
```

#### RDS PostgreSQL 설정

```bash
#!/bin/bash
# setup-rds-postgres.sh

set -e

# 설정 변수
DB_NAME="plane-production"
DB_USERNAME="plane"
DB_PASSWORD="$(openssl rand -hex 32)"
DB_INSTANCE_CLASS="db.r5.large"
SUBNET_GROUP_NAME="plane-db-subnet-group"

echo "🗄️ RDS PostgreSQL 설정 시작"

# 서브넷 그룹 생성
aws rds create-db-subnet-group \
  --db-subnet-group-name $SUBNET_GROUP_NAME \
  --db-subnet-group-description "Plane DB subnet group" \
  --subnet-ids subnet-xxx subnet-yyy subnet-zzz

# RDS 인스턴스 생성
aws rds create-db-instance \
  --db-instance-identifier $DB_NAME \
  --db-instance-class $DB_INSTANCE_CLASS \
  --engine postgres \
  --engine-version 15.4 \
  --master-username $DB_USERNAME \
  --master-user-password $DB_PASSWORD \
  --allocated-storage 100 \
  --storage-type gp3 \
  --storage-encrypted \
  --vpc-security-group-ids sg-xxx \
  --db-subnet-group-name $SUBNET_GROUP_NAME \
  --backup-retention-period 7 \
  --multi-az \
  --monitoring-interval 60 \
  --monitoring-role-arn arn:aws:iam::xxx:role/rds-monitoring-role \
  --enable-performance-insights \
  --performance-insights-retention-period 7 \
  --deletion-protection

echo "🔐 데이터베이스 비밀번호를 기록해두세요: $DB_PASSWORD"
echo "✅ RDS PostgreSQL 설정 완료!"
```

#### AWS용 values-aws-production.yaml

```yaml
# values-aws-production.yaml
plane:
  environment: production
  debug: false
  domain: "plane.yourdomain.com"

# 외부 서비스 사용 (AWS 관리형)
postgresql:
  enabled: false

redis:
  enabled: false

minio:
  enabled: false

# 외부 데이터베이스 설정
externalDatabase:
  url: "postgres://plane:PASSWORD@plane-production.xxx.ap-northeast-2.rds.amazonaws.com:5432/plane"

# 외부 Redis 설정 (ElastiCache)
externalRedis:
  url: "redis://plane-production.xxx.cache.amazonaws.com:6379"

# 외부 스토리지 설정 (S3)
externalStorage:
  type: "s3"
  endpoint: "https://s3.ap-northeast-2.amazonaws.com"
  bucket: "plane-production-files"
  region: "ap-northeast-2"
  accessKey: "your-access-key"
  secretKey: "your-secret-key"

# Ingress 설정 (ALB)
ingress:
  enabled: true
  className: "alb"
  annotations:
    kubernetes.io/ingress.class: "alb"
    alb.ingress.kubernetes.io/scheme: "internet-facing"
    alb.ingress.kubernetes.io/target-type: "ip"
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    alb.ingress.kubernetes.io/ssl-redirect: '443'
    alb.ingress.kubernetes.io/certificate-arn: "arn:aws:acm:ap-northeast-2:xxx:certificate/xxx"
    alb.ingress.kubernetes.io/tags: "Environment=production,Team=devops"

# 스토리지 클래스 설정
global:
  storageClass: "gp3"

# 노드 선택 및 가용성 영역 분산
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: app.kubernetes.io/name
          operator: In
          values: ["plane"]
      topologyKey: "topology.kubernetes.io/zone"

# AWS 특화 리소스 설정
api:
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
    limits:
      memory: "2Gi"
      cpu: "1000m"
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 20
    targetCPUUtilizationPercentage: 70
```

### 2. GCP GKE 배포

#### GKE 클러스터 생성

```bash
#!/bin/bash
# setup-gke-cluster.sh

set -e

# 설정 변수
PROJECT_ID="your-project-id"
CLUSTER_NAME="plane-production"
REGION="asia-northeast3"  # 서울 리전
ZONE="asia-northeast3-a"
KUBERNETES_VERSION="1.28"

echo "☁️ GCP GKE 클러스터 생성 시작"

# GCP 프로젝트 설정
gcloud config set project $PROJECT_ID

# API 활성화
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable sqladmin.googleapis.com

# GKE 클러스터 생성
echo "🏗️ GKE 클러스터 생성 중..."
gcloud container clusters create $CLUSTER_NAME \
  --region $REGION \
  --node-locations $ZONE \
  --cluster-version $KUBERNETES_VERSION \
  --machine-type n2-standard-4 \
  --num-nodes 3 \
  --min-nodes 2 \
  --max-nodes 10 \
  --enable-autoscaling \
  --enable-autorepair \
  --enable-autoupgrade \
  --enable-network-policy \
  --enable-ip-alias \
  --disk-type pd-ssd \
  --disk-size 50 \
  --addons HorizontalPodAutoscaling,HttpLoadBalancing,NetworkPolicy \
  --workload-pool=$PROJECT_ID.svc.id.goog

# kubectl 설정
echo "⚙️ kubectl 설정 중..."
gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION

# 필수 애드온 설치
echo "🔧 GKE 애드온 설치 중..."

# cert-manager 설치
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# NGINX Ingress Controller 설치
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

echo "✅ GKE 클러스터 생성 완료!"
```

#### Cloud SQL 설정

```bash
#!/bin/bash
# setup-cloud-sql.sh

set -e

# 설정 변수
INSTANCE_NAME="plane-production"
DATABASE_VERSION="POSTGRES_15"
TIER="db-custom-4-16384"  # 4 vCPU, 16GB RAM
REGION="asia-northeast3"

echo "🗄️ Cloud SQL PostgreSQL 설정 시작"

# Cloud SQL 인스턴스 생성
gcloud sql instances create $INSTANCE_NAME \
  --database-version=$DATABASE_VERSION \
  --tier=$TIER \
  --region=$REGION \
  --availability-type=REGIONAL \
  --storage-type=SSD \
  --storage-size=100GB \
  --storage-auto-increase \
  --backup-start-time=03:00 \
  --maintenance-window-day=SUN \
  --maintenance-window-hour=04 \
  --enable-bin-log \
  --deletion-protection

# 데이터베이스 생성
gcloud sql databases create plane --instance=$INSTANCE_NAME

# 사용자 생성
DB_PASSWORD="$(openssl rand -hex 32)"
gcloud sql users create plane \
  --instance=$INSTANCE_NAME \
  --password=$DB_PASSWORD

echo "🔐 데이터베이스 비밀번호를 기록해두세요: $DB_PASSWORD"
echo "✅ Cloud SQL PostgreSQL 설정 완료!"
```

#### GCP용 values-gcp-production.yaml

```yaml
# values-gcp-production.yaml
plane:
  environment: production
  debug: false
  domain: "plane.yourdomain.com"

# 외부 서비스 사용 (GCP 관리형)
postgresql:
  enabled: false

redis:
  enabled: false

minio:
  enabled: false

# 외부 데이터베이스 설정
externalDatabase:
  url: "postgres://plane:PASSWORD@xxx.xxx.xxx.xxx:5432/plane"

# 외부 Redis 설정 (Memorystore)
externalRedis:
  url: "redis://xxx.xxx.xxx.xxx:6379"

# 외부 스토리지 설정 (Google Cloud Storage)
externalStorage:
  type: "gcs"
  bucket: "plane-production-files"
  projectId: "your-project-id"
  keyFile: "/path/to/service-account.json"

# Ingress 설정 (GCE)
ingress:
  enabled: true
  className: "gce"
  annotations:
    kubernetes.io/ingress.class: "gce"
    kubernetes.io/ingress.global-static-ip-name: "plane-ip"
    ingress.gcp.kubernetes.io/managed-certificates: "plane-ssl-cert"
    kubernetes.io/ingress.allow-http: "false"

# 스토리지 클래스 설정
global:
  storageClass: "pd-ssd"

# GCP 특화 리소스 설정
api:
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
    limits:
      memory: "2Gi"
      cpu: "1000m"
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 20
```

## 자체 클라우드 구축 완전 가이드

### 1. 하드웨어 요구사항 및 규모별 스펙

#### 소규모 (10-50명 팀)

```yaml
# 최소 하드웨어 스펙
cluster_size: "small"
total_budget: "$3,000 - $5,000"

master_nodes:
  count: 3
  specs:
    cpu: "4 cores (Intel i5 or AMD Ryzen 5)"
    memory: "16GB DDR4"
    storage: "256GB NVMe SSD"
    network: "1Gbps"
  purpose: "쿠버네티스 컨트롤 플레인"
  recommended_hardware:
    - "Intel NUC 13 Pro"
    - "ASUS Mini PC PN53"
    - "Raspberry Pi 4 8GB (개발용)"

worker_nodes:
  count: 3-5
  specs:
    cpu: "8 cores (Intel i7 or AMD Ryzen 7)"
    memory: "32GB DDR4"
    storage: "512GB NVMe SSD"
    network: "1Gbps"
  purpose: "애플리케이션 워크로드"
  recommended_hardware:
    - "Dell OptiPlex Micro"
    - "HP EliteDesk Mini"
    - "Lenovo ThinkCentre Tiny"

storage_nodes:
  count: 1
  specs:
    cpu: "4 cores"
    memory: "16GB"
    storage: "2TB HDD + 256GB SSD (cache)"
    network: "1Gbps"
  purpose: "분산 스토리지 (Longhorn/Ceph)"

networking:
  switch: "24-port Gigabit managed switch"
  router: "Enterprise-grade router with VLAN support"
  estimated_cost: "$300-500"

total_specs:
  cpu_cores: 44
  memory: 176GB
  storage: 3TB
  estimated_users: 50
  estimated_projects: 100
```

#### 중규모 (50-200명 팀)

```yaml
# 중규모 하드웨어 스펙
cluster_size: "medium"
total_budget: "$8,000 - $15,000"

master_nodes:
  count: 3
  specs:
    cpu: "8 cores (Intel Xeon E-2288G or AMD EPYC)"
    memory: "32GB DDR4 ECC"
    storage: "512GB NVMe SSD"
    network: "10Gbps"
  purpose: "고가용성 컨트롤 플레인"
  recommended_hardware:
    - "Dell PowerEdge R340"
    - "HPE ProLiant ML110 Gen10"
    - "Supermicro SYS-E300-9D"

worker_nodes:
  count: 6-10
  specs:
    cpu: "16 cores (Intel Xeon or AMD EPYC)"
    memory: "64GB DDR4 ECC"
    storage: "1TB NVMe SSD"
    network: "10Gbps"
  purpose: "메인 워크로드 처리"
  recommended_hardware:
    - "Dell PowerEdge R450"
    - "HPE ProLiant DL380 Gen10"
    - "Supermicro SuperServer"

storage_nodes:
  count: 3
  specs:
    cpu: "8 cores"
    memory: "32GB"
    storage: "4TB NVMe + 8TB HDD"
    network: "10Gbps"
  purpose: "고성능 분산 스토리지"

networking:
  switch: "48-port 10Gbps managed switch"
  router: "High-performance firewall/router"
  estimated_cost: "$2,000-3,000"

total_specs:
  cpu_cores: 200
  memory: 512GB
  storage: 50TB
  estimated_users: 200
  estimated_projects: 500
```

#### 대규모 (200-1000명 팀)

```yaml
# 대규모 하드웨어 스펙
cluster_size: "large"
total_budget: "$30,000 - $80,000"

master_nodes:
  count: 5
  specs:
    cpu: "24 cores (Intel Xeon Platinum or AMD EPYC)"
    memory: "128GB DDR4 ECC"
    storage: "2TB NVMe SSD"
    network: "25Gbps"
  purpose: "엔터프라이즈급 컨트롤 플레인"
  recommended_hardware:
    - "Dell PowerEdge R750"
    - "HPE ProLiant DL380 Gen10 Plus"
    - "Cisco UCS C240 M6"

worker_nodes:
  count: 15-30
  specs:
    cpu: "32 cores (Intel Xeon Platinum or AMD EPYC)"
    memory: "256GB DDR4 ECC"
    storage: "4TB NVMe SSD"
    network: "25Gbps"
  purpose: "고성능 워크로드 처리"

storage_nodes:
  count: 6
  specs:
    cpu: "16 cores"
    memory: "128GB"
    storage: "8TB NVMe + 32TB HDD"
    network: "25Gbps"
  purpose: "엔터프라이즈 스토리지"

gpu_nodes: # AI/ML 워크로드용
  count: 2-4
  specs:
    cpu: "32 cores"
    memory: "256GB"
    gpu: "4x NVIDIA A100 or H100"
    storage: "8TB NVMe"
    network: "100Gbps InfiniBand"

networking:
  core_switch: "64-port 100Gbps switch"
  access_switches: "48-port 25Gbps switches"
  estimated_cost: "$15,000-25,000"

total_specs:
  cpu_cores: 1000+
  memory: 4TB+
  storage: 500TB+
  estimated_users: 1000+
  estimated_projects: 5000+
```

### 2. 자체 쿠버네티스 클러스터 구축

#### 하드웨어 준비 스크립트

```bash
#!/bin/bash
# hardware-setup.sh

set -e

# 하드웨어 정보 수집
echo "🔍 하드웨어 정보 수집 중..."

# CPU 정보
echo "=== CPU 정보 ==="
lscpu | grep -E "Model name|CPU\(s\)|Core\(s\) per socket|Socket\(s\)"

# 메모리 정보
echo "=== 메모리 정보 ==="
free -h
dmidecode -t memory | grep -E "Size|Speed|Type:" | head -20

# 스토리지 정보
echo "=== 스토리지 정보 ==="
lsblk -d -o NAME,SIZE,TYPE,MODEL
df -h

# 네트워크 정보
echo "=== 네트워크 정보 ==="
ip link show
ethtool eth0 2>/dev/null | grep Speed || echo "네트워크 속도 정보 없음"

# 하드웨어 검증
echo "🧪 하드웨어 검증 중..."

# 최소 요구사항 확인
CPU_CORES=$(nproc)
MEMORY_GB=$(free -g | awk 'NR==2{print $2}')
DISK_GB=$(df / | awk 'NR==2{print int($2/1024/1024)}')

echo "검증 결과:"
echo "  CPU 코어: $CPU_CORES (최소 4개 필요)"
echo "  메모리: ${MEMORY_GB}GB (최소 16GB 필요)"
echo "  디스크: ${DISK_GB}GB (최소 100GB 필요)"

# 요구사항 확인
if [ $CPU_CORES -lt 4 ]; then
    echo "❌ CPU 코어가 부족합니다."
    exit 1
fi

if [ $MEMORY_GB -lt 16 ]; then
    echo "❌ 메모리가 부족합니다."
    exit 1
fi

if [ $DISK_GB -lt 100 ]; then
    echo "❌ 디스크 공간이 부족합니다."
    exit 1
fi

echo "✅ 하드웨어 요구사항을 만족합니다."

# 네트워크 구성 설정
echo "🌐 네트워크 구성 설정 중..."

# 고정 IP 설정 (Ubuntu 22.04 Netplan 기준)
cat << EOF > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - 192.168.1.10/24  # 각 노드별로 다른 IP
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
EOF

netplan apply

echo "✅ 하드웨어 설정 완료!"
```

#### 쿠버네티스 클러스터 설치 스크립트

```bash
#!/bin/bash
# install-k8s-cluster.sh

set -e

# 설정 변수
NODE_TYPE=${1:-master}  # master 또는 worker
CLUSTER_NAME="plane-private"
POD_CIDR="10.244.0.0/16"
SERVICE_CIDR="10.96.0.0/12"

echo "🚀 쿠버네티스 클러스터 설치 시작 (노드 타입: $NODE_TYPE)"

# 시스템 업데이트
echo "📦 시스템 업데이트 중..."
apt-get update && apt-get upgrade -y

# 필수 패키지 설치
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    net-tools \
    htop \
    iotop \
    iftop

# Docker 설치
echo "🐳 Docker 설치 중..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Docker 설정
usermod -aG docker $USER
systemctl enable docker
systemctl start docker

# containerd 설정
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd

# 커널 모듈 및 sysctl 설정
cat << EOF > /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat << EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

modprobe br_netfilter
sysctl --system

# 스왑 비활성화
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# 쿠버네티스 저장소 추가
echo "☸️ 쿠버네티스 설치 중..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# kubelet 설정
echo "KUBELET_EXTRA_ARGS=--container-runtime-endpoint=unix:///var/run/containerd/containerd.sock" > /etc/default/kubelet
systemctl daemon-reload
systemctl restart kubelet

if [ "$NODE_TYPE" = "master" ]; then
    echo "🎯 마스터 노드 초기화 중..."
    
    # 마스터 노드 초기화
    kubeadm init \
        --cluster-name=$CLUSTER_NAME \
        --pod-network-cidr=$POD_CIDR \
        --service-cidr=$SERVICE_CIDR \
        --apiserver-advertise-address=$(hostname -I | awk '{print $1}') \
        --control-plane-endpoint=$(hostname -I | awk '{print $1}'):6443 \
        --upload-certs

    # kubectl 설정
    mkdir -p $HOME/.kube
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config

    # CNI 설치 (Flannel)
    echo "🕸️ CNI 설치 중..."
    kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

    # 조인 토큰 생성 및 저장
    kubeadm token create --print-join-command > /root/join-command.txt
    
    echo "✅ 마스터 노드 설정 완료!"
    echo "워커 노드 조인 명령어:"
    cat /root/join-command.txt

elif [ "$NODE_TYPE" = "worker" ]; then
    echo "👷 워커 노드로 설정됩니다."
    echo "마스터 노드에서 생성된 조인 명령어를 실행하세요:"
    echo "예: kubeadm join 192.168.1.10:6443 --token xxx --discovery-token-ca-cert-hash sha256:xxx"
fi

echo "🎉 쿠버네티스 설치 완료!"
```

#### 고가용성 마스터 노드 설정

```bash
#!/bin/bash
# setup-ha-masters.sh

set -e

# 설정 변수
LOAD_BALANCER_IP="192.168.1.100"
MASTER_NODES=("192.168.1.10" "192.168.1.11" "192.168.1.12")
CLUSTER_NAME="plane-ha"

echo "🔄 고가용성 마스터 노드 설정 시작"

# HAProxy 로드밸런서 설정
if [ "$1" = "setup-lb" ]; then
    echo "⚖️ HAProxy 로드밸런서 설정 중..."
    
    apt-get install -y haproxy
    
    cat << EOF > /etc/haproxy/haproxy.cfg
global
    log stdout local0
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    mode http
    log global
    option httplog
    option dontlognull
    option log-health-checks
    option forwardfor except 127.0.0.0/8
    option redispatch
    retries 3
    timeout http-request 10s
    timeout queue 20s
    timeout connect 10s
    timeout client 20s
    timeout server 20s
    timeout http-keep-alive 10s
    timeout check 10s

frontend kubernetes-frontend
    bind *:6443
    mode tcp
    option tcplog
    default_backend kubernetes-backend

backend kubernetes-backend
    mode tcp
    option tcp-check
    balance roundrobin
    default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100
    server master1 ${MASTER_NODES[0]}:6443 check
    server master2 ${MASTER_NODES[1]}:6443 check
    server master3 ${MASTER_NODES[2]}:6443 check

listen stats
    bind *:8080
    mode http
    stats enable
    stats uri /stats
    stats refresh 30s
    stats admin if TRUE
EOF

    systemctl enable haproxy
    systemctl restart haproxy
    
    echo "✅ HAProxy 설정 완료!"
    echo "상태 확인: http://$LOAD_BALANCER_IP:8080/stats"
    exit 0
fi

# 첫 번째 마스터 노드 초기화
if [ "$1" = "init-first-master" ]; then
    echo "🎯 첫 번째 마스터 노드 초기화 중..."
    
    kubeadm init \
        --cluster-name=$CLUSTER_NAME \
        --control-plane-endpoint="$LOAD_BALANCER_IP:6443" \
        --pod-network-cidr="10.244.0.0/16" \
        --service-cidr="10.96.0.0/12" \
        --upload-certs \
        --apiserver-advertise-address=$(hostname -I | awk '{print $1}')

    # kubectl 설정
    mkdir -p $HOME/.kube
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config

    # CNI 설치
    kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

    # 조인 명령어 생성
    echo "마스터 노드 조인 명령어:" > /root/master-join-command.txt
    kubeadm token create --print-join-command --certificate-key $(kubeadm init phase upload-certs --upload-certs | tail -1) >> /root/master-join-command.txt
    
    echo "워커 노드 조인 명령어:" > /root/worker-join-command.txt
    kubeadm token create --print-join-command >> /root/worker-join-command.txt
    
    echo "✅ 첫 번째 마스터 노드 초기화 완료!"
    cat /root/master-join-command.txt
fi

echo "🎉 고가용성 설정 완료!"
```

### 3. 분산 스토리지 구성 (Longhorn)

#### Longhorn 설치 및 설정

```bash
#!/bin/bash
# setup-longhorn-storage.sh

set -e

echo "💾 Longhorn 분산 스토리지 설치 시작"

# 사전 요구사항 확인
echo "🔍 시스템 요구사항 확인 중..."

# 각 노드에 필요한 패키지 설치
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.5.1/deploy/prerequisite/longhorn-iscsi-installation.yaml

# 설치 확인
echo "⏳ 요구사항 설치 확인 중..."
kubectl get pods -n longhorn-system --selector app=longhorn-iscsi-installation

# Longhorn 네임스페이스 생성
kubectl create namespace longhorn-system

# Longhorn 설치
echo "🚀 Longhorn 설치 중..."
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.5.1/deploy/longhorn.yaml

# 설치 완료 대기
echo "⏳ Longhorn 설치 완료 대기 중..."
kubectl wait --for=condition=available --timeout=600s deployment/longhorn-manager -n longhorn-system
kubectl wait --for=condition=available --timeout=600s deployment/longhorn-driver-deployer -n longhorn-system

# 기본 스토리지 클래스 설정
cat << EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: longhorn-retain
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: driver.longhorn.io
allowVolumeExpansion: true
reclaimPolicy: Retain
volumeBindingMode: Immediate
parameters:
  numberOfReplicas: "3"
  staleReplicaTimeout: "2880"
  fromBackup: ""
  fsType: "ext4"
  dataLocality: "disabled"
EOF

# 성능 최적화 스토리지 클래스
cat << EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: longhorn-fast
provisioner: driver.longhorn.io
allowVolumeExpansion: true
parameters:
  numberOfReplicas: "2"
  staleReplicaTimeout: "30"
  fromBackup: ""
  fsType: "ext4"
  dataLocality: "best-effort"
  diskSelector: "ssd"
  nodeSelector: "storage"
EOF

# 백업 스토리지 클래스
cat << EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: longhorn-backup
provisioner: driver.longhorn.io
allowVolumeExpansion: true
parameters:
  numberOfReplicas: "3"
  staleReplicaTimeout: "2880"
  fromBackup: ""
  fsType: "ext4"
  recurringJobSelector: '[{"name":"backup", "isGroup":true}]'
EOF

# 백업 작업 생성
cat << EOF | kubectl apply -f -
apiVersion: longhorn.io/v1beta2
kind: RecurringJob
metadata:
  name: daily-backup
  namespace: longhorn-system
spec:
  cron: "0 2 * * *"
  task: "backup"
  groups:
  - backup
  retain: 14
  concurrency: 2
  labels:
    recurring-job: "daily-backup"
EOF

echo "✅ Longhorn 설치 완료!"
echo "📊 대시보드 접근: kubectl port-forward -n longhorn-system svc/longhorn-frontend 8080:80"
```

#### 자체 클라우드용 values-private.yaml

```yaml
# values-private.yaml
plane:
  environment: production
  debug: false
  domain: "plane.yourdomain.com"

# 모든 서비스 내장 사용
postgresql:
  enabled: true
  auth:
    postgresPassword: "your-secure-password"
    username: "plane"
    password: "your-secure-password"
    database: "plane"
  
  primary:
    persistence:
      enabled: true
      size: 100Gi
      storageClass: "longhorn-retain"
    
    resources:
      requests:
        memory: "2Gi"
        cpu: "1000m"
      limits:
        memory: "4Gi"
        cpu: "2000m"
        
    configuration: |-
      max_connections = 500
      shared_buffers = 1GB
      effective_cache_size = 3GB
      maintenance_work_mem = 256MB
      checkpoint_completion_target = 0.9
      wal_buffers = 16MB
      default_statistics_target = 100
      random_page_cost = 1.1
      effective_io_concurrency = 200
      work_mem = 4MB
      min_wal_size = 1GB
      max_wal_size = 4GB

redis:
  enabled: true
  auth:
    enabled: true
    password: "your-redis-password"
    
  master:
    persistence:
      enabled: true
      size: 20Gi
      storageClass: "longhorn-fast"
      
    resources:
      requests:
        memory: "1Gi"
        cpu: "500m"
      limits:
        memory: "2Gi"
        cpu: "1000m"
        
    configuration: |-
      maxmemory 1gb
      maxmemory-policy allkeys-lru
      appendonly yes
      appendfsync everysec
      save 900 1
      save 300 10
      save 60 10000

minio:
  enabled: true
  auth:
    rootUser: "plane"
    rootPassword: "your-minio-password"
    
  persistence:
    enabled: true
    size: 500Gi
    storageClass: "longhorn-retain"
    
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
    limits:
      memory: "2Gi"
      cpu: "1000m"

# 고성능 애플리케이션 설정
api:
  replicaCount: 5
  resources:
    requests:
      memory: "2Gi"
      cpu: "1000m"
    limits:
      memory: "4Gi"
      cpu: "2000m"
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 20
    targetCPUUtilizationPercentage: 60

worker:
  replicaCount: 3
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
    limits:
      memory: "2Gi"
      cpu: "1000m"
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 15

web:
  replicaCount: 3
  resources:
    requests:
      memory: "512Mi"
      cpu: "250m"
    limits:
      memory: "1Gi"
      cpu: "500m"
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10

# 스토리지 클래스 설정
global:
  storageClass: "longhorn-retain"

# 고가용성 설정
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values: ["plane"]
        topologyKey: kubernetes.io/hostname

# 노드 선택자 (성능 최적화)
nodeSelector:
  node-type: "worker"

# 모니터링 활성화
serviceMonitor:
  enabled: true
  interval: 15s

# 네트워크 정책 활성화
networkPolicy:
  enabled: true

# 백업 설정
backup:
  enabled: true
  schedule: "0 2 * * *"
  retention: 14
```

## 완전한 모니터링 & 로깅 시스템

### 1. Prometheus + Grafana 스택 설치

```bash
#!/bin/bash
# setup-monitoring.sh

set -e

echo "📊 Prometheus + Grafana 모니터링 스택 설치 시작"

# Helm 저장소 추가
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# 모니터링 네임스페이스 생성
kubectl create namespace monitoring

# Prometheus 설치
echo "🔍 Prometheus 설치 중..."
cat << EOF > prometheus-values.yaml
prometheus:
  prometheusSpec:
    retention: 30d
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: longhorn-retain
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi
    
    resources:
      requests:
        memory: 2Gi
        cpu: 1000m
      limits:
        memory: 4Gi
        cpu: 2000m
    
    nodeSelector:
      node-type: "worker"

alertmanager:
  alertmanagerSpec:
    storage:
      volumeClaimTemplate:
        spec:
          storageClassName: longhorn-retain
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi
    
    resources:
      requests:
        memory: 256Mi
        cpu: 100m
      limits:
        memory: 512Mi
        cpu: 200m

grafana:
  enabled: true
  persistence:
    enabled: true
    storageClassName: longhorn-retain
    size: 10Gi
  
  adminPassword: "your-grafana-password"
  
  resources:
    requests:
      memory: 512Mi
      cpu: 250m
    limits:
      memory: 1Gi
      cpu: 500m

nodeExporter:
  enabled: true

kubeStateMetrics:
  enabled: true

prometheusOperator:
  enabled: true
  
  resources:
    requests:
      memory: 512Mi
      cpu: 250m
    limits:
      memory: 1Gi
      cpu: 500m
EOF

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values prometheus-values.yaml

# Grafana 대시보드 설정
echo "📈 Grafana 대시보드 설정 중..."

# Plane 전용 대시보드
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: plane-dashboard
  namespace: monitoring
  labels:
    grafana_dashboard: "1"
data:
  plane-dashboard.json: |
    {
      "dashboard": {
        "id": null,
        "title": "Plane Monitoring Dashboard",
        "tags": ["plane", "kubernetes"],
        "timezone": "browser",
        "panels": [
          {
            "id": 1,
            "title": "API Response Time",
            "type": "graph",
            "targets": [
              {
                "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{job=\"plane-api\"}[5m])) by (le))",
                "refId": "A"
              }
            ],
            "yAxes": [
              {
                "label": "Response Time (s)",
                "min": 0
              }
            ]
          },
          {
            "id": 2,
            "title": "API Request Rate",
            "type": "graph",
            "targets": [
              {
                "expr": "sum(rate(http_requests_total{job=\"plane-api\"}[5m])) by (method, status)",
                "refId": "A"
              }
            ]
          },
          {
            "id": 3,
            "title": "Database Connections",
            "type": "graph",
            "targets": [
              {
                "expr": "pg_stat_database_numbackends{datname=\"plane\"}",
                "refId": "A"
              }
            ]
          },
          {
            "id": 4,
            "title": "Worker Queue Length",
            "type": "graph",
            "targets": [
              {
                "expr": "redis_list_length{key=\"celery\"}",
                "refId": "A"
              }
            ]
          }
        ],
        "time": {
          "from": "now-6h",
          "to": "now"
        },
        "refresh": "30s"
      }
    }
EOF

echo "✅ Prometheus + Grafana 설치 완료!"
echo "🔗 접근 정보:"
echo "   Prometheus: kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"
echo "   Grafana: kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "   Grafana 기본 로그인: admin / your-grafana-password"
```

### 2. ELK 스택 (Elasticsearch + Logstash + Kibana) 설치

```bash
#!/bin/bash
# setup-logging.sh

set -e

echo "📝 ELK 스택 로깅 시스템 설치 시작"

# Elastic 저장소 추가
helm repo add elastic https://helm.elastic.co
helm repo update

# 로깅 네임스페이스 생성
kubectl create namespace logging

# Elasticsearch 설치
echo "🔍 Elasticsearch 설치 중..."
cat << EOF > elasticsearch-values.yaml
replicas: 3
minimumMasterNodes: 2

esConfig:
  elasticsearch.yml: |
    cluster.name: "plane-logs"
    network.host: 0.0.0.0
    discovery.type: zen
    discovery.zen.minimum_master_nodes: 2
    discovery.zen.ping.unicast.hosts: ["elasticsearch-master-headless"]
    xpack.security.enabled: false
    xpack.monitoring.collection.enabled: true

resources:
  requests:
    cpu: "1000m"
    memory: "2Gi"
  limits:
    cpu: "2000m"
    memory: "4Gi"

volumeClaimTemplate:
  accessModes: ["ReadWriteOnce"]
  storageClassName: "longhorn-retain"
  resources:
    requests:
      storage: 100Gi

nodeSelector:
  node-type: "worker"
EOF

helm install elasticsearch elastic/elasticsearch \
  --namespace logging \
  --values elasticsearch-values.yaml

# Kibana 설치
echo "📊 Kibana 설치 중..."
cat << EOF > kibana-values.yaml
elasticsearchHosts: "http://elasticsearch-master:9200"

resources:
  requests:
    cpu: "500m"
    memory: "1Gi"
  limits:
    cpu: "1000m"
    memory: "2Gi"

service:
  type: ClusterIP
  port: 5601

ingress:
  enabled: true
  className: "nginx"
  annotations:
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: kibana-auth
  hosts:
    - host: kibana.yourdomain.com
      paths:
        - path: /
          pathType: Prefix

kibanaConfig:
  kibana.yml: |
    server.host: 0.0.0.0
    elasticsearch.hosts: ["http://elasticsearch-master:9200"]
    logging.dest: stdout
    logging.silent: false
    logging.quiet: false
    logging.verbose: false
EOF

helm install kibana elastic/kibana \
  --namespace logging \
  --values kibana-values.yaml

# Filebeat 설치 (로그 수집)
echo "📁 Filebeat 설치 중..."
cat << EOF > filebeat-values.yaml
daemonset:
  enabled: true

deployment:
  enabled: false

filebeatConfig:
  filebeat.yml: |
    filebeat.inputs:
    - type: container
      paths:
        - /var/log/containers/*.log
      processors:
        - add_kubernetes_metadata:
            host: \${NODE_NAME}
            matchers:
            - logs_path:
                logs_path: "/var/log/containers/"
        - drop_fields:
            fields: ["host", "agent", "ecs", "log", "input"]
    
    processors:
      - add_cloud_metadata: ~
      - add_host_metadata: ~
      - add_docker_metadata: ~
      - add_kubernetes_metadata: ~
    
    output.elasticsearch:
      hosts: ["elasticsearch-master:9200"]
      index: "plane-logs-%{+yyyy.MM.dd}"
      template.name: "plane-logs"
      template.pattern: "plane-logs-*"
      template.settings:
        index.number_of_shards: 3
        index.number_of_replicas: 1
        index.codec: best_compression
        index.refresh_interval: 5s
    
    setup.template.enabled: true
    setup.template.name: "plane-logs"
    setup.template.pattern: "plane-logs-*"

resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "200m"
    memory: "256Mi"

extraVolumes:
  - name: varlog
    hostPath:
      path: /var/log
  - name: varlibdockercontainers
    hostPath:
      path: /var/lib/docker/containers

extraVolumeMounts:
  - name: varlog
    mountPath: /var/log
    readOnly: true
  - name: varlibdockercontainers
    mountPath: /var/lib/docker/containers
    readOnly: true
EOF

helm install filebeat elastic/filebeat \
  --namespace logging \
  --values filebeat-values.yaml

# Kibana 인증 설정
echo "🔐 Kibana 인증 설정 중..."
htpasswd -bc /tmp/auth admin your-kibana-password
kubectl create secret generic kibana-auth \
  --from-file=/tmp/auth \
  --namespace logging

echo "✅ ELK 스택 설치 완료!"
echo "🔗 접근 정보:"
echo "   Elasticsearch: kubectl port-forward -n logging svc/elasticsearch-master 9200:9200"
echo "   Kibana: kubectl port-forward -n logging svc/kibana-kibana 5601:5601"
echo "   Kibana 로그인: admin / your-kibana-password"
```

### 3. 알림 시스템 설정

{% raw %}
```bash
#!/bin/bash
# setup-alerting.sh

set -e

echo "🚨 알림 시스템 설정 시작"

# AlertManager 설정
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager-config
  namespace: monitoring
data:
  alertmanager.yml: |
    global:
      smtp_smarthost: 'smtp.gmail.com:587'
      smtp_from: 'alerts@yourdomain.com'
      smtp_auth_username: 'alerts@yourdomain.com'
      smtp_auth_password: 'your-email-password'
    
    route:
      group_by: ['alertname', 'cluster', 'service']
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 12h
      receiver: 'default'
      routes:
      - match:
          severity: 'critical'
        receiver: 'critical-alerts'
      - match:
          severity: 'warning'
        receiver: 'warning-alerts'
    
    receivers:
    - name: 'default'
      email_configs:
      - to: 'admin@yourdomain.com'
        subject: '[Plane] {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
    
    - name: 'critical-alerts'
      email_configs:
      - to: 'admin@yourdomain.com'
        subject: '[CRITICAL] Plane Alert'
        body: |
          {{ range .Alerts }}
          CRITICAL ALERT: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
      slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'
        channel: '#alerts'
        title: 'Critical Plane Alert'
        text: |
          {{ range .Alerts }}
          {{ .Annotations.summary }}
          {{ end }}
    
    - name: 'warning-alerts'
      email_configs:
      - to: 'admin@yourdomain.com'
        subject: '[WARNING] Plane Alert'
        body: |
          {{ range .Alerts }}
          WARNING: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
EOF

# Plane 전용 알림 규칙
cat << EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: plane-alerts
  namespace: monitoring
  labels:
    prometheus: kube-prometheus
    role: alert-rules
spec:
  groups:
  - name: plane.rules
    rules:
    - alert: PlaneAPIHighResponseTime
      expr: histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{job="plane-api"}[5m])) by (le)) > 2
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Plane API high response time"
        description: "API 95th percentile response time is {{ \$value }}s"
    
    - alert: PlaneAPIHighErrorRate
      expr: sum(rate(http_requests_total{job="plane-api",status=~"5.."}[5m])) / sum(rate(http_requests_total{job="plane-api"}[5m])) > 0.1
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Plane API high error rate"
        description: "API error rate is {{ \$value | humanizePercentage }}"
    
    - alert: PlaneDatabaseConnectionsHigh
      expr: pg_stat_database_numbackends{datname="plane"} > 80
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Plane database connections high"
        description: "Database has {{ \$value }} active connections"
    
    - alert: PlaneWorkerQueueBacklog
      expr: redis_list_length{key="celery"} > 1000
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "Plane worker queue backlog"
        description: "Worker queue has {{ \$value }} pending tasks"
    
    - alert: PlanePodCrashLooping
      expr: rate(kube_pod_container_status_restarts_total{namespace="plane"}[5m]) > 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Plane pod crash looping"
        description: "Pod {{ \$labels.pod }} is crash looping"
    
    - alert: PlaneStorageSpaceLow
      expr: (kubelet_volume_stats_available_bytes{namespace="plane"} / kubelet_volume_stats_capacity_bytes{namespace="plane"}) < 0.1
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Plane storage space low"
        description: "Storage {{ \$labels.persistentvolumeclaim }} has less than 10% free space"
EOF

echo "✅ 알림 시스템 설정 완료!"
```
{% endraw %}

## 엔터프라이즈 보안 강화

### 1. RBAC 및 네트워크 정책

```bash
#!/bin/bash
# setup-security.sh

set -e

echo "🔒 보안 설정 시작"

# Plane 전용 서비스 계정 및 RBAC 설정
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: plane-api
  namespace: plane
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: plane-api-role
  namespace: plane
rules:
- apiGroups: [""]
  resources: ["pods", "services", "endpoints"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: plane-api-binding
  namespace: plane
subjects:
- kind: ServiceAccount
  name: plane-api
  namespace: plane
roleRef:
  kind: Role
  name: plane-api-role
  apiGroup: rbac.authorization.k8s.io
EOF

# 네트워크 정책 설정
cat << EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: plane-network-policy
  namespace: plane
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: plane
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    - podSelector:
        matchLabels:
          app.kubernetes.io/name: plane
    ports:
    - protocol: TCP
      port: 8000
    - protocol: TCP
      port: 3000
  egress:
  - to:
    - podSelector:
        matchLabels:
          app.kubernetes.io/name: postgresql
    ports:
    - protocol: TCP
      port: 5432
  - to:
    - podSelector:
        matchLabels:
          app.kubernetes.io/name: redis
    ports:
    - protocol: TCP
      port: 6379
  - to:
    - podSelector:
        matchLabels:
          app.kubernetes.io/name: minio
    ports:
    - protocol: TCP
      port: 9000
  - to: []
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 80
EOF

# Pod Security Standards 설정
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: plane
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
EOF

echo "✅ 보안 설정 완료!"
```

### 2. SSL/TLS 인증서 자동 관리

```bash
#!/bin/bash
# setup-ssl.sh

set -e

echo "🔐 SSL/TLS 인증서 설정 시작"

# cert-manager 설치
helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl create namespace cert-manager

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.13.0 \
  --set installCRDs=true

# Let's Encrypt 발급자 설정
cat << EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@yourdomain.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: admin@yourdomain.com
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

# 인증서 템플릿
cat << EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: plane-tls
  namespace: plane
spec:
  secretName: plane-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
  - plane.yourdomain.com
  - api.plane.yourdomain.com
  - admin.plane.yourdomain.com
EOF

echo "✅ SSL/TLS 설정 완료!"
```

## GitOps CI/CD 파이프라인 (ArgoCD)

### 1. ArgoCD 설치 및 설정

```bash
#!/bin/bash
# setup-gitops.sh

set -e

echo "🚀 ArgoCD GitOps 파이프라인 설정 시작"

# ArgoCD 네임스페이스 생성
kubectl create namespace argocd

# ArgoCD 설치
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# ArgoCD 서버 대기
echo "⏳ ArgoCD 서버 시작 대기 중..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# ArgoCD CLI 설치
echo "🔧 ArgoCD CLI 설치 중..."
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd

# ArgoCD 초기 비밀번호 얻기
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "🔐 ArgoCD 초기 admin 비밀번호: $ARGOCD_PASSWORD"

# ArgoCD 설정 커스터마이징
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-cm
    app.kubernetes.io/part-of: argocd
data:
  url: "https://argocd.yourdomain.com"
  dex.config: |
    connectors:
    - type: github
      id: github
      name: GitHub
      config:
        clientID: your-github-client-id
        clientSecret: your-github-client-secret
        orgs:
        - name: your-org
          teams:
          - your-team
  policy.default: role:readonly
  policy.csv: |
    p, role:admin, applications, *, */*, allow
    p, role:admin, certificates, *, *, allow
    p, role:admin, clusters, *, *, allow
    p, role:admin, repositories, *, *, allow
    g, your-org:your-team, role:admin
EOF

# Ingress 설정
cat << EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "GRPC"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - argocd.yourdomain.com
    secretName: argocd-server-tls
  rules:
  - host: argocd.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 443
EOF

echo "✅ ArgoCD 설치 완료!"
echo "🔗 ArgoCD URL: https://argocd.yourdomain.com"
echo "👤 기본 로그인: admin / $ARGOCD_PASSWORD"
```

### 2. Plane GitOps 애플리케이션 설정

```bash
#!/bin/bash
# setup-plane-gitops.sh

set -e

echo "📦 Plane GitOps 애플리케이션 설정 시작"

# Git 저장소 등록
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: plane-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  type: git
  url: https://github.com/your-org/plane-k8s-config
  password: your-github-token
  username: your-github-username
EOF

# Plane 개발 환경 애플리케이션
cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: plane-dev
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/plane-k8s-config
    targetRevision: develop
    path: plane-helm
    helm:
      valueFiles:
      - values-dev.yaml
      parameters:
      - name: plane.image.tag
        value: develop
  destination:
    server: https://kubernetes.default.svc
    namespace: plane-dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
EOF

# Plane 스테이징 환경 애플리케이션
cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: plane-staging
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/plane-k8s-config
    targetRevision: main
    path: plane-helm
    helm:
      valueFiles:
      - values-staging.yaml
      parameters:
      - name: plane.image.tag
        value: staging
  destination:
    server: https://kubernetes.default.svc
    namespace: plane-staging
  syncPolicy:
    syncOptions:
    - CreateNamespace=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
EOF

# Plane 운영 환경 애플리케이션 (수동 동기화)
cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: plane-production
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/plane-k8s-config
    targetRevision: main
    path: plane-helm
    helm:
      valueFiles:
      - values-production.yaml
      parameters:
      - name: plane.image.tag
        value: v1.0.0
  destination:
    server: https://kubernetes.default.svc
    namespace: plane
  syncPolicy:
    syncOptions:
    - CreateNamespace=true
    retry:
      limit: 3
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
EOF

echo "✅ Plane GitOps 애플리케이션 설정 완료!"
```

### 3. GitHub Actions CI/CD 파이프라인

```yaml
# .github/workflows/plane-cicd.yml
name: Plane CI/CD Pipeline

on:
  push:
    branches: [main, develop]
    tags: ['v*']
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: $`github.repository`/plane

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: plane_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
      
      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        pip install -r requirements.txt
        pip install pytest coverage
    
    - name: Run tests
      env:
        DATABASE_URL: postgresql://postgres:postgres@localhost:5432/plane_test
        REDIS_URL: redis://localhost:6379
      run: |
        coverage run -m pytest
        coverage xml
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3

  security-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: '.'
        format: 'sarif'
        output: 'trivy-results.sarif'
    
    - name: Upload Trivy scan results to GitHub Security tab
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'

  build-and-push:
    needs: [test, security-scan]
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
      image-digest: ${{ steps.build.outputs.digest }}
    
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
          type=semver,pattern={{version}}
          type=semver,pattern={{major}}.{{minor}}
          type=sha,prefix={{branch}}-
    
    - name: Build and push Docker image
      id: build
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
        platforms: linux/amd64,linux/arm64

  deploy-dev:
    needs: build-and-push
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    environment: development
    
    steps:
    - name: Update ArgoCD Application
      run: |
        curl -X PATCH \
          -H "Authorization: Bearer ${{ secrets.ARGOCD_TOKEN }}" \
          -H "Content-Type: application/json" \
          -d '{
            "spec": {
              "source": {
                "helm": {
                  "parameters": [
                    {
                      "name": "plane.image.tag",
                      "value": "develop-$`github.sha`"
                    }
                  ]
                }
              }
            }
          }' \
          https://argocd.yourdomain.com/api/v1/applications/plane-dev

  deploy-staging:
    needs: build-and-push
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: staging
    
    steps:
    - name: Update ArgoCD Application
      run: |
        curl -X PATCH \
          -H "Authorization: Bearer ${{ secrets.ARGOCD_TOKEN }}" \
          -H "Content-Type: application/json" \
          -d '{
            "spec": {
              "source": {
                "helm": {
                  "parameters": [
                    {
                      "name": "plane.image.tag",
                      "value": "main-$`github.sha`"
                    }
                  ]
                }
              }
            }
          }' \
          https://argocd.yourdomain.com/api/v1/applications/plane-staging

  deploy-production:
    needs: build-and-push
    runs-on: ubuntu-latest
    if: startsWith(github.ref, 'refs/tags/v')
    environment: production
    
    steps:
    - name: Update ArgoCD Application
      run: |
        curl -X PATCH \
          -H "Authorization: Bearer ${{ secrets.ARGOCD_TOKEN }}" \
          -H "Content-Type: application/json" \
          -d '{
            "spec": {
              "source": {
                "helm": {
                  "parameters": [
                    {
                      "name": "plane.image.tag",
                      "value": "$`github.ref_name`"
                    }
                  ]
                }
              }
            }
          }' \
          https://argocd.yourdomain.com/api/v1/applications/plane-production
        
        # Sync the application
        curl -X POST \
          -H "Authorization: Bearer ${{ secrets.ARGOCD_TOKEN }}" \
          -H "Content-Type: application/json" \
          https://argocd.yourdomain.com/api/v1/applications/plane-production/sync
```

## 백업 & 복구 전략

### 1. 데이터베이스 백업 자동화

```bash
#!/bin/bash
# setup-backup.sh

set -e

echo "💾 백업 시스템 설정 시작"

# 백업 네임스페이스 생성
kubectl create namespace backup

# Velero 설치 (쿠버네티스 백업 도구)
echo "📦 Velero 설치 중..."
curl -fsSL -o velero-v1.12.0-linux-amd64.tar.gz https://github.com/vmware-tanzu/velero/releases/download/v1.12.0/velero-v1.12.0-linux-amd64.tar.gz
tar -xzf velero-v1.12.0-linux-amd64.tar.gz
sudo mv velero-v1.12.0-linux-amd64/velero /usr/local/bin/

# MinIO 백업 서버 설정 (자체 클라우드용)
cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backup-minio
  namespace: backup
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backup-minio
  template:
    metadata:
      labels:
        app: backup-minio
    spec:
      containers:
      - name: minio
        image: minio/minio:latest
        args:
        - server
        - /data
        - --console-address
        - ":9001"
        env:
        - name: MINIO_ROOT_USER
          value: "backupuser"
        - name: MINIO_ROOT_PASSWORD
          value: "backuppassword123"
        ports:
        - containerPort: 9000
        - containerPort: 9001
        volumeMounts:
        - name: backup-storage
          mountPath: /data
      volumes:
      - name: backup-storage
        persistentVolumeClaim:
          claimName: backup-storage-pvc
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: backup-storage-pvc
  namespace: backup
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: longhorn-retain
  resources:
    requests:
      storage: 1Ti
---
apiVersion: v1
kind: Service
metadata:
  name: backup-minio
  namespace: backup
spec:
  selector:
    app: backup-minio
  ports:
  - name: api
    port: 9000
    targetPort: 9000
  - name: console
    port: 9001
    targetPort: 9001
EOF

# Velero 설치 (MinIO 백엔드)
echo "🔧 Velero 설정 중..."
cat << EOF > velero-credentials
[default]
aws_access_key_id = backupuser
aws_secret_access_key = backuppassword123
EOF

kubectl create secret generic cloud-credentials \
  --namespace velero \
  --from-file cloud=velero-credentials

velero install \
  --provider aws \
  --plugins velero/velero-plugin-for-aws:v1.8.0 \
  --bucket velero-backups \
  --secret-file ./velero-credentials \
  --use-volume-snapshots=false \
  --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://backup-minio.backup:9000

# 데이터베이스 백업 CronJob
cat << EOF | kubectl apply -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: postgres-backup
  namespace: plane
spec:
  schedule: "0 2 * * *"  # 매일 새벽 2시
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: postgres-backup
            image: postgres:15
            env:
            - name: PGPASSWORD
              valueFrom:
                secretKeyRef:
                  name: plane-postgresql
                  key: postgres-password
            command:
            - /bin/bash
            - -c
            - |
              BACKUP_FILE="plane-backup-\$(date +%Y%m%d_%H%M%S).sql"
              pg_dump -h plane-postgresql -U plane plane > /backup/\$BACKUP_FILE
              gzip /backup/\$BACKUP_FILE
              
              # 7일 이상 된 백업 파일 삭제
              find /backup -name "*.sql.gz" -mtime +7 -delete
              
              echo "백업 완료: \$BACKUP_FILE.gz"
            volumeMounts:
            - name: backup-volume
              mountPath: /backup
          volumes:
          - name: backup-volume
            persistentVolumeClaim:
              claimName: postgres-backup-pvc
          restartPolicy: OnFailure
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-backup-pvc
  namespace: plane
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: longhorn-retain
  resources:
    requests:
      storage: 50Gi
EOF

# 전체 클러스터 백업 스케줄
cat << EOF | kubectl apply -f -
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: daily-backup
  namespace: velero
spec:
  schedule: "0 3 * * *"  # 매일 새벽 3시
  template:
    includedNamespaces:
    - plane
    - monitoring
    - logging
    ttl: 720h  # 30일 보관
    storageLocation: default
EOF

# 주간 전체 백업
cat << EOF | kubectl apply -f -
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: weekly-full-backup
  namespace: velero
spec:
  schedule: "0 1 * * 0"  # 매주 일요일 새벽 1시
  template:
    ttl: 2160h  # 90일 보관
    storageLocation: default
EOF

echo "✅ 백업 시스템 설정 완료!"
echo "📋 백업 확인 명령어:"
echo "   velero backup get"
echo "   velero schedule get"
```

### 2. 복구 절차 스크립트

```bash
#!/bin/bash
# disaster-recovery.sh

set -e

BACKUP_NAME=${1}
RESTORE_TYPE=${2:-full}  # full, database, namespace

if [ -z "$BACKUP_NAME" ]; then
    echo "사용법: $0 <백업이름> [full|database|namespace]"
    echo "백업 목록 확인: velero backup get"
    exit 1
fi

echo "🚨 재해복구 시작: $BACKUP_NAME ($RESTORE_TYPE)"

case $RESTORE_TYPE in
    full)
        echo "🔄 전체 시스템 복구 중..."
        velero restore create $BACKUP_NAME-restore --from-backup $BACKUP_NAME
        ;;
    
    database)
        echo "🗄️ 데이터베이스 복구 중..."
        # 현재 DB 중지
        kubectl scale deployment plane-api --replicas=0 -n plane
        kubectl scale deployment plane-worker --replicas=0 -n plane
        
        # 백업에서 복구
        velero restore create $BACKUP_NAME-db-restore \
          --from-backup $BACKUP_NAME \
          --include-resources persistentvolumeclaims,persistentvolumes \
          --selector app.kubernetes.io/name=postgresql
        
        # 서비스 재시작
        kubectl scale deployment plane-api --replicas=3 -n plane
        kubectl scale deployment plane-worker --replicas=2 -n plane
        ;;
    
    namespace)
        NAMESPACE=${3:-plane}
        echo "📦 네임스페이스 복구 중: $NAMESPACE"
        velero restore create $BACKUP_NAME-ns-restore \
          --from-backup $BACKUP_NAME \
          --include-namespaces $NAMESPACE
        ;;
    
    *)
        echo "❌ 지원하지 않는 복구 타입: $RESTORE_TYPE"
        exit 1
        ;;
esac

echo "⏳ 복구 상태 확인 중..."
sleep 30

velero restore describe $BACKUP_NAME-*-restore

echo "✅ 재해복구 완료!"
echo "🔍 확인 명령어:"
echo "   kubectl get pods -n plane"
echo "   kubectl logs -f deployment/plane-api -n plane"
```

## 성능 최적화 & 문제 해결

### 1. 성능 튜닝 스크립트

```bash
#!/bin/bash
# performance-tuning.sh

set -e

echo "⚡ 성능 최적화 시작"

# 1. 노드 레벨 최적화
echo "🖥️ 노드 레벨 최적화 중..."

# CPU Governor 설정
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [ -f "$cpu" ] && echo performance > "$cpu"
done

# TCP 버퍼 크기 최적화
cat << EOF > /etc/sysctl.d/99-kubernetes-performance.conf
# 네트워크 성능 최적화
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728
net.ipv4.tcp_congestion_control = bbr

# 파일 시스템 최적화
fs.file-max = 1000000
vm.swappiness = 1
vm.dirty_ratio = 20
vm.dirty_background_ratio = 5

# 쿠버네티스 최적화
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sysctl -p /etc/sysctl.d/99-kubernetes-performance.conf

# 2. 쿠버네티스 클러스터 최적화
echo "☸️ 쿠버네티스 클러스터 최적화 중..."

# HPA 커스텀 메트릭 설정
cat << EOF | kubectl apply -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: plane-api-advanced-hpa
  namespace: plane
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: plane-api
  minReplicas: 3
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 70
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "100"
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 60
      - type: Pods
        value: 2
        periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
EOF

# VPA (Vertical Pod Autoscaler) 설정
cat << EOF | kubectl apply -f -
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: plane-api-vpa
  namespace: plane
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: plane-api
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: api
      minAllowed:
        cpu: 500m
        memory: 1Gi
      maxAllowed:
        cpu: 4000m
        memory: 8Gi
      controlledResources: ["cpu", "memory"]
EOF

# 3. 데이터베이스 최적화
echo "🗄️ 데이터베이스 최적화 중..."

cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-performance-config
  namespace: plane
data:
  postgresql.conf: |
    # 연결 설정
    max_connections = 500
    shared_buffers = 4GB
    effective_cache_size = 12GB
    
    # 메모리 설정
    work_mem = 16MB
    maintenance_work_mem = 1GB
    
    # WAL 설정
    wal_buffers = 64MB
    min_wal_size = 2GB
    max_wal_size = 8GB
    checkpoint_completion_target = 0.9
    
    # 쿼리 최적화
    random_page_cost = 1.1
    effective_io_concurrency = 200
    default_statistics_target = 100
    
    # 로깅 설정
    log_min_duration_statement = 1000
    log_checkpoints = on
    log_connections = on
    log_disconnections = on
    log_lock_waits = on
    
    # 병렬 처리
    max_worker_processes = 16
    max_parallel_workers_per_gather = 4
    max_parallel_workers = 16
    max_parallel_maintenance_workers = 4
EOF

echo "✅ 성능 최적화 완료!"
```

### 2. 종합 문제 해결 가이드

```bash
#!/bin/bash
# troubleshooting-guide.sh

set -e

ISSUE_TYPE=${1:-health-check}

echo "🔧 Plane 문제 해결 도구"

health_check() {
    echo "🏥 시스템 전체 상태 확인 중..."
    
    echo "=== 쿠버네티스 클러스터 상태 ==="
    kubectl cluster-info
    kubectl get nodes -o wide
    
    echo "=== Plane 네임스페이스 상태 ==="
    kubectl get all -n plane
    
    echo "=== 스토리지 상태 ==="
    kubectl get pv,pvc -n plane
    
    echo "=== 최근 이벤트 ==="
    kubectl get events -n plane --sort-by='.lastTimestamp' | tail -20
    
    echo "=== 리소스 사용량 ==="
    kubectl top nodes
    kubectl top pods -n plane
}

pod_issues() {
    echo "🐛 Pod 문제 진단 중..."
    
    echo "=== 실패한 Pod 목록 ==="
    kubectl get pods -n plane --field-selector=status.phase=Failed
    
    echo "=== Pending Pod 목록 ==="
    kubectl get pods -n plane --field-selector=status.phase=Pending
    
    echo "=== 재시작 많은 Pod ==="
    kubectl get pods -n plane --sort-by='.status.containerStatuses[0].restartCount' | tail -10
    
    for pod in $(kubectl get pods -n plane -o jsonpath='{.items[?(@.status.phase!="Running")].metadata.name}'); do
        echo "=== Pod $pod 상세 정보 ==="
        kubectl describe pod $pod -n plane
        echo "=== Pod $pod 로그 ==="
        kubectl logs $pod -n plane --tail=50
    done
}

network_issues() {
    echo "🌐 네트워크 문제 진단 중..."
    
    echo "=== 서비스 상태 ==="
    kubectl get svc -n plane -o wide
    
    echo "=== Ingress 상태 ==="
    kubectl get ingress -n plane -o wide
    
    echo "=== NetworkPolicy 상태 ==="
    kubectl get networkpolicy -n plane
    
    echo "=== DNS 테스트 ==="
    kubectl run dns-test --image=busybox:1.35 --rm -it --restart=Never -- nslookup kubernetes.default
}

storage_issues() {
    echo "💾 스토리지 문제 진단 중..."
    
    echo "=== PV/PVC 상태 ==="
    kubectl get pv,pvc -A
    
    echo "=== 스토리지 클래스 ==="
    kubectl get storageclass
    
    echo "=== Longhorn 상태 (있는 경우) ==="
    kubectl get pods -n longhorn-system 2>/dev/null || echo "Longhorn이 설치되지 않음"
    
    echo "=== 디스크 사용량 ==="
    for node in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
        echo "Node: $node"
        kubectl debug node/$node -it --image=busybox:1.35 -- df -h
    done
}

performance_issues() {
    echo "⚡ 성능 문제 진단 중..."
    
    echo "=== 리소스 사용량 상위 Pod ==="
    kubectl top pods -n plane --sort-by=cpu | head -10
    kubectl top pods -n plane --sort-by=memory | head -10
    
    echo "=== HPA 상태 ==="
    kubectl get hpa -n plane
    kubectl describe hpa -n plane
    
    echo "=== 메트릭 서버 상태 ==="
    kubectl get pods -n kube-system | grep metrics-server
    
    echo "=== API 응답 시간 테스트 ==="
    API_URL=$(kubectl get ingress -n plane -o jsonpath='{.items[0].spec.rules[0].host}')
    if [ -n "$API_URL" ]; then
        curl -w "@curl-format.txt" -o /dev/null -s "https://$API_URL/api/health/"
    fi
}

backup_issues() {
    echo "💾 백업 문제 진단 중..."
    
    echo "=== Velero 상태 ==="
    kubectl get pods -n velero
    
    echo "=== 백업 상태 ==="
    velero backup get
    
    echo "=== 최근 백업 로그 ==="
    RECENT_BACKUP=$(velero backup get -o jsonpath='{.items[0].metadata.name}')
    if [ -n "$RECENT_BACKUP" ]; then
        velero backup logs $RECENT_BACKUP
    fi
}

auto_fix() {
    echo "🔨 자동 복구 시도 중..."
    
    # Stuck pods 재시작
    for pod in $(kubectl get pods -n plane --field-selector=status.phase=Pending -o jsonpath='{.items[*].metadata.name}'); do
        echo "Pod $pod 재시작 중..."
        kubectl delete pod $pod -n plane
    done
    
    # Failed jobs 정리
    kubectl delete job --field-selector=status.successful=0 -n plane
    
    # 리소스 정리
    kubectl delete pod --field-selector=status.phase=Succeeded -n plane
    kubectl delete pod --field-selector=status.phase=Failed -n plane
    
    # DNS 캐시 정리
    kubectl delete pod -n kube-system -l k8s-app=kube-dns
    
    echo "✅ 자동 복구 완료"
}

case $ISSUE_TYPE in
    health-check|health)
        health_check
        ;;
    pod|pods)
        pod_issues
        ;;
    network)
        network_issues
        ;;
    storage)
        storage_issues
        ;;
    performance|perf)
        performance_issues
        ;;
    backup)
        backup_issues
        ;;
    auto-fix|fix)
        auto_fix
        ;;
    all)
        health_check
        pod_issues
        network_issues
        storage_issues
        performance_issues
        backup_issues
        ;;
    *)
        echo "사용법: $0 [health-check|pods|network|storage|performance|backup|auto-fix|all]"
        exit 1
        ;;
esac

echo "🎯 문제 해결 완료!"
```

## 시리즈 마무리

### 운영 체크리스트

```bash
#!/bin/bash
# daily-operations-checklist.sh

echo "📋 Plane 일일 운영 체크리스트"
echo "날짜: $(date)"
echo "==============================="

echo "✅ 1. 시스템 상태 확인"
kubectl get nodes
kubectl get pods -n plane

echo "✅ 2. 리소스 사용량 확인"
kubectl top nodes
kubectl top pods -n plane

echo "✅ 3. 스토리지 용량 확인"
kubectl get pvc -n plane

echo "✅ 4. 백업 상태 확인"
velero backup get | head -5

echo "✅ 5. 알림 확인"
kubectl get alerts -A 2>/dev/null || echo "알림 없음"

echo "✅ 6. 로그 검토 (최근 1시간)"
kubectl logs -n plane deployment/plane-api --since=1h | grep -i error | tail -10

echo "==============================="
echo "체크리스트 완료: $(date)"
```

## 결론

이 **Plane 엔터프라이즈 쿠버네티스 운영 가이드**를 통해 다음을 완전히 마스터했습니다:

### 🎯 핵심 성과
- **Helm 차트**: 환경별 맞춤 배포 패키지 완성
- **멀티 클라우드**: AWS, GCP, 자체 클라우드 모든 환경 대응
- **하드웨어 가이드**: 10명~10,000명 규모별 최적화된 스펙
- **완전한 모니터링**: Prometheus + Grafana + ELK 통합 관측성
- **엔터프라이즈 보안**: RBAC, 네트워크 정책, SSL/TLS 자동화
- **GitOps CI/CD**: ArgoCD 기반 완전 자동화된 배포
- **재해복구**: Velero 백업 및 복구 전략
- **성능 최적화**: HPA, VPA, 데이터베이스 튜닝

### 🚀 다음 단계
1. **환경에 맞는 설정 선택**: AWS/GCP/자체 클라우드 중 선택
2. **단계별 구축**: 개발 → 스테이징 → 운영 순서로 진행
3. **모니터링 구축**: 관측성 먼저, 그 다음 보안
4. **GitOps 도입**: 수동 배포에서 자동화로 전환
5. **지속적 개선**: 메트릭 기반 성능 최적화

### 📚 시리즈 연결
이 시리즈의 다른 글들:
- **1편**: [Plane 프로젝트 관리 완전 가이드](#)
- **2편**: [Plane GitHub 통합 고급 가이드](#)
- **3편**: [Plane 쿠버네티스 운영 배포 가이드](#)
- **4편**: 현재 글 - Plane 엔터프라이즈 쿠버네티스 운영 가이드

### 💡 마지막 팁
> "완벽한 시스템은 없지만, 지속적으로 개선하는 시스템은 있습니다. 모니터링으로 현상을 파악하고, 자동화로 반복을 줄이며, 백업으로 안전을 확보하세요."

**엔터프라이즈 Plane 운영**의 모든 것을 다뤘습니다. 이제 여러분의 팀에 맞는 최적의 프로젝트 관리 환경을 구축해보세요! 🎯 