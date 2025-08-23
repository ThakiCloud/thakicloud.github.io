---
title: "Plane 쿠버네티스 운영 완전 가이드 - OrbStack부터 Production까지"
excerpt: "Plane을 macOS OrbStack에서 테스트하고 실제 쿠버네티스 운영 환경으로 배포하는 완전 가이드. Helm 차트, 모니터링, CI/CD, 보안 설정까지 엔터프라이즈급 운영 노하우를 담았습니다."
seo_title: "Plane 쿠버네티스 운영 완전 가이드 - OrbStack Production 배포 - Thaki Cloud"
seo_description: "Plane 쿠버네티스 배포 가이드. macOS OrbStack 테스트부터 AWS EKS GCP GKE 운영까지. Helm Monitoring CI/CD 보안 설정 완전 정복"
date: 2025-07-01
last_modified_at: 2025-07-01
categories:
  - tutorials
tags:
  - plane
  - kubernetes
  - orbstack
  - helm
  - eks
  - gke
  - production
  - monitoring
  - cicd
  - devops
  - cloud-native
  - container-orchestration
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/plane-kubernetes-production-deployment-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 25분

## 서론

[첫 번째 글](#)에서 Plane의 기본 설치를, [두 번째 글](#)에서 GitHub 연동과 API 자동화를 다뤘다면, 이번에는 **엔터프라이즈급 운영**을 위한 쿠버네티스 배포에 집중하겠습니다.

이 가이드에서는 **개발부터 운영까지** 전체 라이프사이클을 다룹니다:

- 🖥️ **OrbStack 개발 환경**: macOS에서 빠른 쿠버네티스 테스트
- ⚙️ **Helm 차트 구성**: 재사용 가능한 배포 패키지 
- ☁️ **클라우드 운영**: AWS EKS, GCP GKE 실전 배포
- 📊 **모니터링 & 로깅**: Prometheus, Grafana, ELK 스택
- 🔒 **보안 & 백업**: RBAC, 네트워크 정책, 데이터 보호
- 🚀 **CI/CD 파이프라인**: GitOps로 자동 배포

## OrbStack 개발 환경 설정

### 1. OrbStack이란?

**OrbStack**은 macOS에서 Docker와 쿠버네티스를 실행하는 혁신적인 도구입니다. Docker Desktop의 강력한 대안으로, **10배 빠른 시작 속도**와 **2배 적은 메모리 사용량**을 자랑합니다.

#### 주요 특징
- **네이티브 성능**: Apple Silicon 최적화
- **빠른 시작**: 5초 이내 컨테이너 실행
- **쿠버네티스 내장**: 별도 설치 없이 K8s 클러스터 제공
- **통합 네트워킹**: localhost로 직접 접근 가능

### 2. OrbStack 설치

```bash
# Homebrew를 통한 설치
brew install orbstack

# 또는 공식 웹사이트에서 다운로드
# https://orbstack.dev/download

# 설치 확인
orb version
```

### 3. 쿠버네티스 클러스터 활성화

```bash
# OrbStack 실행 후 쿠버네티스 활성화
orb create --kubernetes my-plane-cluster

# kubectl 컨텍스트 확인
kubectl config current-context

# 클러스터 상태 확인
kubectl cluster-info
kubectl get nodes
```

**OrbStack의 장점:**
```bash
# 즉시 사용 가능한 LoadBalancer
kubectl get svc -A | grep LoadBalancer

# 빠른 이미지 빌드 (BuildKit 지원)
docker build -t plane-test . --platform linux/arm64
```

## Plane Kubernetes 매니페스트 작성

### 1. 네임스페이스 및 기본 리소스

```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: plane
  labels:
    name: plane
    app: plane-project-management
---
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: plane-config
  namespace: plane
data:
  # 환경 설정
  NODE_ENV: "production"
  DEBUG: "0"
  CORS_ALLOWED_ORIGINS: "https://plane.yourdomain.com"
  
  # 데이터베이스 설정
  POSTGRES_HOST: "plane-postgresql"
  POSTGRES_PORT: "5432"
  POSTGRES_DB: "plane"
  
  # Redis 설정
  REDIS_HOST: "plane-redis"
  REDIS_PORT: "6379"
  
  # MinIO 설정
  MINIO_ROOT_USER: "plane"
  MINIO_ROOT_PASSWORD: "plane123"
  USE_MINIO: "1"
  
  # 애플리케이션 URL
  WEB_URL: "https://plane.yourdomain.com"
  ADMIN_BASE_URL: "https://plane.yourdomain.com/admin"
  SPACE_BASE_URL: "https://plane.yourdomain.com/spaces"
```

### 2. Secret 관리

```yaml
# secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: plane-secrets
  namespace: plane
type: Opaque
data:
  # Base64로 인코딩된 값들
  POSTGRES_PASSWORD: cGxhbmVfcGFzc3dvcmQ=  # plane_password
  SECRET_KEY: c3VwZXJfc2VjcmV0X2tleV9mb3JfcGxhbmU=    # super_secret_key_for_plane
  GITHUB_CLIENT_SECRET: Z2l0aHViX2NsaWVudF9zZWNyZXQ=  # github_client_secret
  SLACK_WEBHOOK_URL: aHR0cHM6Ly9ob29rcy5zbGFjay5jb20v  # https://hooks.slack.com/
  
---
# secret을 생성하는 스크립트
# create-secrets.sh
#!/bin/bash

kubectl create secret generic plane-secrets \
  --from-literal=POSTGRES_PASSWORD="$(openssl rand -hex 32)" \
  --from-literal=SECRET_KEY="$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')" \
  --from-literal=GITHUB_CLIENT_SECRET="your_github_client_secret" \
  --from-literal=SLACK_WEBHOOK_URL="your_slack_webhook_url" \
  --namespace=plane
```

### 3. Persistent Volume 설정

```yaml
# storage.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: plane-postgresql-pvc
  namespace: plane
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
  storageClassName: fast-ssd
  
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: plane-minio-pvc
  namespace: plane
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi
  storageClassName: fast-ssd
  
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: plane-redis-pvc
  namespace: plane
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: fast-ssd
```

## PostgreSQL 배포

### 1. PostgreSQL StatefulSet

```yaml
# postgresql.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: plane-postgresql
  namespace: plane
spec:
  serviceName: plane-postgresql
  replicas: 1
  selector:
    matchLabels:
      app: plane-postgresql
  template:
    metadata:
      labels:
        app: plane-postgresql
    spec:
      containers:
      - name: postgresql
        image: postgres:15.7-alpine
        env:
        - name: POSTGRES_DB
          valueFrom:
            configMapKeyRef:
              name: plane-config
              key: POSTGRES_DB
        - name: POSTGRES_USER
          value: "plane"
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: plane-secrets
              key: POSTGRES_PASSWORD
        - name: PGDATA
          value: /var/lib/postgresql/data/pgdata
        ports:
        - containerPort: 5432
          name: postgresql
        volumeMounts:
        - name: postgresql-data
          mountPath: /var/lib/postgresql/data
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        livenessProbe:
          exec:
            command:
              - /bin/sh
              - -c
              - exec pg_isready -U plane -h 127.0.0.1 -p 5432
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
        readinessProbe:
          exec:
            command:
              - /bin/sh
              - -c
              - exec pg_isready -U plane -h 127.0.0.1 -p 5432
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
      volumes:
      - name: postgresql-data
        persistentVolumeClaim:
          claimName: plane-postgresql-pvc
          
---
apiVersion: v1
kind: Service
metadata:
  name: plane-postgresql
  namespace: plane
spec:
  selector:
    app: plane-postgresql
  ports:
  - port: 5432
    targetPort: 5432
    name: postgresql
  type: ClusterIP
```

### 2. PostgreSQL 초기화 작업

```yaml
# postgresql-init-job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: plane-db-migration
  namespace: plane
spec:
  template:
    spec:
      restartPolicy: OnFailure
      containers:
      - name: db-migration
        image: makeplane/plane-backend:latest
        command: ["/bin/sh"]
        args:
          - -c
          - |
            python manage.py wait_for_db
            python manage.py migrate --settings=plane.settings.production
            python manage.py collectstatic --noinput --settings=plane.settings.production
        env:
        - name: DATABASE_URL
          value: "postgres://plane:$(POSTGRES_PASSWORD)@plane-postgresql:5432/plane"
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: plane-secrets
              key: POSTGRES_PASSWORD
        envFrom:
        - configMapRef:
            name: plane-config
        - secretRef:
            name: plane-secrets
```

## Redis 배포

### 1. Redis Deployment

```yaml
# redis.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: plane-redis
  namespace: plane
spec:
  replicas: 1
  selector:
    matchLabels:
      app: plane-redis
  template:
    metadata:
      labels:
        app: plane-redis
    spec:
      containers:
      - name: redis
        image: redis:7.2-alpine
        command:
          - redis-server
          - --appendonly
          - "yes"
          - --maxmemory
          - "256mb"
          - --maxmemory-policy
          - "allkeys-lru"
        ports:
        - containerPort: 6379
          name: redis
        volumeMounts:
        - name: redis-data
          mountPath: /data
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          exec:
            command:
              - redis-cli
              - ping
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
              - redis-cli
              - ping
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: redis-data
        persistentVolumeClaim:
          claimName: plane-redis-pvc
          
---
apiVersion: v1
kind: Service
metadata:
  name: plane-redis
  namespace: plane
spec:
  selector:
    app: plane-redis
  ports:
  - port: 6379
    targetPort: 6379
    name: redis
  type: ClusterIP
```

## MinIO 배포

### 1. MinIO StatefulSet

```yaml
# minio.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: plane-minio
  namespace: plane
spec:
  serviceName: plane-minio
  replicas: 1
  selector:
    matchLabels:
      app: plane-minio
  template:
    metadata:
      labels:
        app: plane-minio
    spec:
      containers:
      - name: minio
        image: minio/minio:latest
        command:
        - /bin/bash
        - -c
        args:
        - minio server /export --console-address ":9090"
        env:
        - name: MINIO_ROOT_USER
          valueFrom:
            configMapKeyRef:
              name: plane-config
              key: MINIO_ROOT_USER
        - name: MINIO_ROOT_PASSWORD
          valueFrom:
            configMapKeyRef:
              name: plane-config
              key: MINIO_ROOT_PASSWORD
        ports:
        - containerPort: 9000
          name: minio
        - containerPort: 9090
          name: minio-console
        volumeMounts:
        - name: minio-data
          mountPath: /export
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /minio/health/live
            port: 9000
          initialDelaySeconds: 30
          periodSeconds: 20
        readinessProbe:
          httpGet:
            path: /minio/health/ready
            port: 9000
          initialDelaySeconds: 10
          periodSeconds: 10
      volumes:
      - name: minio-data
        persistentVolumeClaim:
          claimName: plane-minio-pvc
          
---
apiVersion: v1
kind: Service
metadata:
  name: plane-minio
  namespace: plane
spec:
  selector:
    app: plane-minio
  ports:
  - port: 9000
    targetPort: 9000
    name: minio
  - port: 9090
    targetPort: 9090
    name: minio-console
  type: ClusterIP
```

### 2. MinIO 버킷 초기화

```yaml
# minio-init-job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: plane-minio-init
  namespace: plane
spec:
  template:
    spec:
      restartPolicy: OnFailure
      containers:
      - name: minio-init
        image: minio/mc:latest
        command: ["/bin/sh"]
        args:
          - -c
          - |
            until mc alias set plane http://plane-minio:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD; do
              echo "Waiting for MinIO..."
              sleep 2
            done
            mc mb plane/uploads --ignore-existing
            mc policy set public plane/uploads
            echo "MinIO initialization completed"
        env:
        - name: MINIO_ROOT_USER
          valueFrom:
            configMapKeyRef:
              name: plane-config
              key: MINIO_ROOT_USER
        - name: MINIO_ROOT_PASSWORD
          valueFrom:
            configMapKeyRef:
              name: plane-config
              key: MINIO_ROOT_PASSWORD
```

## Plane 애플리케이션 배포

### 1. API 서버 배포

```yaml
# plane-api.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: plane-api
  namespace: plane
  labels:
    app: plane-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: plane-api
  template:
    metadata:
      labels:
        app: plane-api
    spec:
      initContainers:
      - name: wait-for-db
        image: busybox:1.35
        command: ['sh', '-c']
        args:
          - |
            until nc -z plane-postgresql 5432; do
              echo "Waiting for PostgreSQL..."
              sleep 2
            done
            echo "PostgreSQL is ready!"
      containers:
      - name: plane-api
        image: makeplane/plane-backend:latest
        ports:
        - containerPort: 8000
          name: http
        env:
        - name: DATABASE_URL
          value: "postgres://plane:$(POSTGRES_PASSWORD)@plane-postgresql:5432/plane"
        - name: REDIS_URL
          value: "redis://plane-redis:6379"
        envFrom:
        - configMapRef:
            name: plane-config
        - secretRef:
            name: plane-secrets
        resources:
          requests:
            memory: "512Mi"
            cpu: "200m"
          limits:
            memory: "1Gi"
            cpu: "500m"
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
        volumeMounts:
        - name: static-files
          mountPath: /app/static
      volumes:
      - name: static-files
        emptyDir: {}
      
---
apiVersion: v1
kind: Service
metadata:
  name: plane-api
  namespace: plane
spec:
  selector:
    app: plane-api
  ports:
  - port: 8000
    targetPort: 8000
    name: http
  type: ClusterIP
```

### 2. Worker 서비스 배포

```yaml
# plane-worker.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: plane-worker
  namespace: plane
  labels:
    app: plane-worker
spec:
  replicas: 2
  selector:
    matchLabels:
      app: plane-worker
  template:
    metadata:
      labels:
        app: plane-worker
    spec:
      containers:
      - name: plane-worker
        image: makeplane/plane-backend:latest
        command: ["celery"]
        args: ["-A", "plane.settings.celery", "worker", "-l", "info"]
        env:
        - name: DATABASE_URL
          value: "postgres://plane:$(POSTGRES_PASSWORD)@plane-postgresql:5432/plane"
        - name: REDIS_URL
          value: "redis://plane-redis:6379"
        envFrom:
        - configMapRef:
            name: plane-config
        - secretRef:
            name: plane-secrets
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "200m"
        livenessProbe:
          exec:
            command:
              - /bin/sh
              - -c
              - "celery -A plane.settings.celery inspect ping"
          initialDelaySeconds: 60
          periodSeconds: 30
          
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: plane-beat
  namespace: plane
  labels:
    app: plane-beat
spec:
  replicas: 1
  selector:
    matchLabels:
      app: plane-beat
  template:
    metadata:
      labels:
        app: plane-beat
    spec:
      containers:
      - name: plane-beat
        image: makeplane/plane-backend:latest
        command: ["celery"]
        args: ["-A", "plane.settings.celery", "beat", "-l", "info"]
        env:
        - name: DATABASE_URL
          value: "postgres://plane:$(POSTGRES_PASSWORD)@plane-postgresql:5432/plane"
        - name: REDIS_URL
          value: "redis://plane-redis:6379"
        envFrom:
        - configMapRef:
            name: plane-config
        - secretRef:
            name: plane-secrets
        resources:
          requests:
            memory: "128Mi"
            cpu: "50m"
          limits:
            memory: "256Mi"
            cpu: "100m"
```

### 3. Web 애플리케이션 배포

```yaml
# plane-web.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: plane-web
  namespace: plane
  labels:
    app: plane-web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: plane-web
  template:
    metadata:
      labels:
        app: plane-web
    spec:
      containers:
      - name: plane-web
        image: makeplane/plane-frontend:latest
        ports:
        - containerPort: 3000
          name: http
        env:
        - name: NEXT_PUBLIC_API_BASE_URL
          value: "https://plane.yourdomain.com/api"
        - name: NEXT_PUBLIC_DEPLOY_URL
          value: "https://plane.yourdomain.com"
        envFrom:
        - configMapRef:
            name: plane-config
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /
            port: 3000
          initialDelaySeconds: 10
          periodSeconds: 10
      
---
apiVersion: v1
kind: Service
metadata:
  name: plane-web
  namespace: plane
spec:
  selector:
    app: plane-web
  ports:
  - port: 3000
    targetPort: 3000
    name: http
  type: ClusterIP
```

### 4. Admin 패널 배포

```yaml
# plane-admin.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: plane-admin
  namespace: plane
  labels:
    app: plane-admin
spec:
  replicas: 1
  selector:
    matchLabels:
      app: plane-admin
  template:
    metadata:
      labels:
        app: plane-admin
    spec:
      containers:
      - name: plane-admin
        image: makeplane/plane-admin:latest
        ports:
        - containerPort: 3001
          name: http
        env:
        - name: NEXT_PUBLIC_API_BASE_URL
          value: "https://plane.yourdomain.com/api"
        - name: NEXT_PUBLIC_ADMIN_BASE_URL
          value: "https://plane.yourdomain.com/admin"
        envFrom:
        - configMapRef:
            name: plane-config
        resources:
          requests:
            memory: "128Mi"
            cpu: "50m"
          limits:
            memory: "256Mi"
            cpu: "100m"
      
---
apiVersion: v1
kind: Service
metadata:
  name: plane-admin
  namespace: plane
spec:
  selector:
    app: plane-admin
  ports:
  - port: 3001
    targetPort: 3001
    name: http
  type: ClusterIP
```

## Ingress 및 네트워킹 설정

### 1. NGINX Ingress Controller 설치

```bash
# OrbStack에서 NGINX Ingress Controller 설치
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# 설치 확인
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

### 2. SSL 인증서 설정 (Let's Encrypt)

```yaml
# cert-manager-issuer.yaml
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
```

### 3. Ingress 리소스 구성

```yaml
# plane-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: plane-ingress
  namespace: plane
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
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
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - plane.yourdomain.com
    secretName: plane-tls
  rules:
  - host: plane.yourdomain.com
    http:
      paths:
      # API 라우팅
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: plane-api
            port:
              number: 8000
      # Admin 패널 라우팅
      - path: /admin
        pathType: Prefix
        backend:
          service:
            name: plane-admin
            port:
              number: 3001
      # MinIO 파일 업로드 라우팅
      - path: /uploads
        pathType: Prefix
        backend:
          service:
            name: plane-minio
            port:
              number: 9000
      # 메인 웹 애플리케이션 (기본값)
      - path: /
        pathType: Prefix
        backend:
          service:
            name: plane-web
            port:
              number: 3000
```

### 4. 네트워크 정책 설정

```yaml
# network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: plane-network-policy
  namespace: plane
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  # Ingress Controller로부터의 트래픽 허용
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
  # 네임스페이스 내부 통신 허용
  - from:
    - namespaceSelector:
        matchLabels:
          name: plane
  egress:
  # DNS 해결을 위한 kube-system 접근
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
  # 네임스페이스 내부 통신 허용
  - to:
    - namespaceSelector:
        matchLabels:
          name: plane
  # 외부 서비스 접근 (GitHub, Slack 등)
  - to: []
    ports:
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 80
```

## OrbStack에서 테스트

### 1. 전체 배포 스크립트

```bash
#!/bin/bash
# deploy-plane-orbstack.sh

set -e

echo "🚀 Plane 쿠버네티스 배포 시작..."

# 네임스페이스 생성
kubectl apply -f namespace.yaml

# Secret 생성
echo "🔐 Secret 생성 중..."
chmod +x create-secrets.sh
./create-secrets.sh

# ConfigMap 및 PVC 생성
kubectl apply -f configmap.yaml
kubectl apply -f storage.yaml

# 데이터베이스 및 캐시 배포
echo "🗄️ 데이터베이스 서비스 배포 중..."
kubectl apply -f postgresql.yaml
kubectl apply -f redis.yaml
kubectl apply -f minio.yaml

# 데이터베이스 초기화 대기
echo "⏳ 데이터베이스 초기화 대기 중..."
kubectl wait --for=condition=available --timeout=300s deployment/plane-redis -n plane
kubectl wait --for=condition=ready --timeout=300s pod -l app=plane-postgresql -n plane

# DB 마이그레이션 실행
echo "📊 데이터베이스 마이그레이션 실행 중..."
kubectl apply -f postgresql-init-job.yaml
kubectl apply -f minio-init-job.yaml

# 마이그레이션 완료 대기
kubectl wait --for=condition=complete --timeout=300s job/plane-db-migration -n plane
kubectl wait --for=condition=complete --timeout=300s job/plane-minio-init -n plane

# 애플리케이션 배포
echo "🎯 Plane 애플리케이션 배포 중..."
kubectl apply -f plane-api.yaml
kubectl apply -f plane-worker.yaml
kubectl apply -f plane-web.yaml
kubectl apply -f plane-admin.yaml

# 애플리케이션 준비 대기
echo "⏳ 애플리케이션 시작 대기 중..."
kubectl wait --for=condition=available --timeout=300s deployment/plane-api -n plane
kubectl wait --for=condition=available --timeout=300s deployment/plane-web -n plane

# Ingress 설정
echo "🌐 Ingress 설정 중..."
kubectl apply -f plane-ingress.yaml

echo "✅ 배포 완료!"
echo ""
echo "📋 배포 상태 확인:"
kubectl get pods -n plane
echo ""
echo "🌐 서비스 접근:"
echo "   Web: http://localhost"
echo "   API: http://localhost/api"
echo "   Admin: http://localhost/admin"
echo ""
echo "🔍 로그 확인:"
echo "   kubectl logs -f deployment/plane-api -n plane"
echo "   kubectl logs -f deployment/plane-web -n plane"
```

### 2. OrbStack 전용 설정

```yaml
# orbstack-loadbalancer.yaml
apiVersion: v1
kind: Service
metadata:
  name: plane-loadbalancer
  namespace: plane
  annotations:
    # OrbStack LoadBalancer 설정
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  type: LoadBalancer
  selector:
    app: plane-web
  ports:
  - port: 80
    targetPort: 3000
    name: http
  - port: 8000
    targetPort: 8000
    name: api

---
# OrbStack 개발용 간단한 Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: plane-dev-ingress
  namespace: plane
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: plane-api
            port:
              number: 8000
      - path: /admin
        pathType: Prefix
        backend:
          service:
            name: plane-admin
            port:
              number: 3001
      - path: /
        pathType: Prefix
        backend:
          service:
            name: plane-web
            port:
              number: 3000
```

### 3. 개발 환경 테스트 스크립트

```bash
#!/bin/bash
# test-plane-orbstack.sh

echo "🧪 Plane OrbStack 테스트 시작..."

# 포드 상태 확인
echo "📊 포드 상태:"
kubectl get pods -n plane -o wide

# 서비스 상태 확인
echo -e "\n🌐 서비스 상태:"
kubectl get svc -n plane

# Ingress 상태 확인
echo -e "\n🚪 Ingress 상태:"
kubectl get ingress -n plane

# API 헬스체크
echo -e "\n🏥 API 헬스체크:"
API_POD=$(kubectl get pods -n plane -l app=plane-api -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n plane $API_POD -- curl -s http://localhost:8000/api/health/ || echo "API 헬스체크 실패"

# 웹 애플리케이션 접근 테스트
echo -e "\n🌍 웹 애플리케이션 테스트:"
WEB_POD=$(kubectl get pods -n plane -l app=plane-web -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n plane $WEB_POD -- curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 || echo "웹 애플리케이션 접근 실패"

# 데이터베이스 연결 테스트
echo -e "\n🗄️ 데이터베이스 연결 테스트:"
DB_POD=$(kubectl get pods -n plane -l app=plane-postgresql -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n plane $DB_POD -- pg_isready -U plane && echo "데이터베이스 연결 성공" || echo "데이터베이스 연결 실패"

# Redis 연결 테스트
echo -e "\n🚀 Redis 연결 테스트:"
REDIS_POD=$(kubectl get pods -n plane -l app=plane-redis -o jsonPath='{.items[0].metadata.name}')
kubectl exec -n plane $REDIS_POD -- redis-cli ping && echo "Redis 연결 성공" || echo "Redis 연결 실패"

# MinIO 접근 테스트
echo -e "\n📦 MinIO 접근 테스트:"
MINIO_POD=$(kubectl get pods -n plane -l app=plane-minio -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n plane $MINIO_POD -- curl -s -o /dev/null -w "%{http_code}" http://localhost:9000/minio/health/live || echo "MinIO 접근 실패"

# 로그 확인
echo -e "\n📜 최근 로그 (마지막 10줄):"
echo "API 로그:"
kubectl logs --tail=10 -n plane deployment/plane-api
echo -e "\nWeb 로그:"
kubectl logs --tail=10 -n plane deployment/plane-web

echo -e "\n✅ 테스트 완료!"

# 접근 URL 출력
INGRESS_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
if [ -n "$INGRESS_IP" ]; then
    echo "🌐 접근 가능한 URL:"
    echo "   Web: http://$INGRESS_IP"
    echo "   API: http://$INGRESS_IP/api"
    echo "   Admin: http://$INGRESS_IP/admin"
else
    echo "🌐 로컬 접근:"
    echo "   kubectl port-forward -n plane svc/plane-web 3000:3000"
    echo "   kubectl port-forward -n plane svc/plane-api 8000:8000"
fi
```

### 4. 개발 편의 도구

```bash
#!/bin/bash
# plane-dev-tools.sh

# 빠른 포트 포워딩
plane_port_forward() {
    echo "🚀 포트 포워딩 시작..."
    
    # 백그라운드에서 실행
    kubectl port-forward -n plane svc/plane-web 3000:3000 &
    kubectl port-forward -n plane svc/plane-api 8000:8000 &
    kubectl port-forward -n plane svc/plane-admin 3001:3001 &
    kubectl port-forward -n plane svc/plane-minio 9090:9090 &
    
    echo "✅ 포트 포워딩 완료:"
    echo "   Web: http://localhost:3000"
    echo "   API: http://localhost:8000"
    echo "   Admin: http://localhost:3001"
    echo "   MinIO Console: http://localhost:9090"
    
    # 포트 포워딩 중지를 위한 PID 저장
    jobs -p > /tmp/plane-port-forward.pids
    echo "중지하려면: kill \$(cat /tmp/plane-port-forward.pids)"
}

# 로그 스트리밍
plane_logs() {
    local service=${1:-api}
    echo "📜 $service 로그 스트리밍..."
    kubectl logs -f -n plane deployment/plane-$service
}

# 리소스 사용량 모니터링
plane_monitor() {
    watch kubectl top pods -n plane
}

# 데이터베이스 접속
plane_db() {
    local DB_POD=$(kubectl get pods -n plane -l app=plane-postgresql -o jsonpath='{.items[0].metadata.name}')
    kubectl exec -it -n plane $DB_POD -- psql -U plane -d plane
}

# Redis CLI 접속
plane_redis() {
    local REDIS_POD=$(kubectl get pods -n plane -l app=plane-redis -o jsonpath='{.items[0].metadata.name}')
    kubectl exec -it -n plane $REDIS_POD -- redis-cli
}

# 사용법 출력
case "$1" in
    port-forward|pf)
        plane_port_forward
        ;;
    logs)
        plane_logs $2
        ;;
    monitor|top)
        plane_monitor
        ;;
    db)
        plane_db
        ;;
    redis)
        plane_redis
        ;;
    *)
        echo "Plane 개발 도구 사용법:"
        echo "  $0 port-forward  # 포트 포워딩 시작"
        echo "  $0 logs [api|web|worker]  # 로그 스트리밍"
        echo "  $0 monitor       # 리소스 모니터링"
        echo "  $0 db           # 데이터베이스 접속"
        echo "  $0 redis        # Redis CLI 접속"
        ;;
esac
``` 