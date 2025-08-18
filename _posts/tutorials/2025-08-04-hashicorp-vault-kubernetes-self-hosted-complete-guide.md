---
title: "HashiCorp Vault Kubernetes Self-Hosted 완전 가이드 - 시크릿 관리의 새로운 패러다임"
excerpt: "HashiCorp Vault를 Kubernetes 클러스터에 Self-Hosted로 배포하고 운영하는 완전한 튜토리얼. 시크릿 관리, 암호화 서비스, 권한 관리의 모든 것을 다룹니다."
seo_title: "HashiCorp Vault Kubernetes Self-Hosted 완전 가이드 - Thaki Cloud"
seo_description: "HashiCorp Vault를 Kubernetes에 배포하여 시크릿 관리, 암호화 서비스, 권한 관리를 구현하는 완전한 튜토리얼 가이드"
date: 2025-08-04
last_modified_at: 2025-08-04
categories:
  - tutorials
  - devops
tags:
  - hashicorp-vault
  - kubernetes
  - secrets-management
  - devops
  - security
  - encryption
  - self-hosted
  - infrastructure
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/hashicorp-vault-kubernetes-self-hosted-complete-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 25분

## 🔍 서론

현대적인 클라우드 네이티브 환경에서 시크릿 관리와 보안은 가장 중요한 과제 중 하나입니다. 애플리케이션이 분산되고 마이크로서비스 아키텍처가 일반화되면서, 데이터베이스 비밀번호, API 키, 인증서 등의 민감한 정보를 안전하게 관리하는 것이 필수적이 되었습니다.

HashiCorp Vault는 이러한 문제를 해결하기 위해 설계된 강력한 시크릿 관리 및 암호화 플랫폼입니다. 이 튜토리얼에서는 Vault의 핵심 개념을 이해하고, Kubernetes 클러스터에 Self-Hosted로 배포하여 운영하는 방법을 단계별로 학습합니다.

### 📋 학습 목표

- HashiCorp Vault의 핵심 개념과 아키텍처 이해
- 다른 시크릿 관리 솔루션과의 비교 분석
- Kubernetes 클러스터에 Vault 배포
- Vault 운영 및 모니터링 설정
- 실제 사용 사례 및 모범 사례 학습

---

## 🏗️ HashiCorp Vault 소개

### 🔐 Vault란 무엇인가?

HashiCorp Vault는 시크릿 관리, 암호화 서비스, 권한 관리(Privileged Access Management)를 위한 통합 플랫폼입니다. Vault는 다음과 같은 핵심 기능을 제공합니다:

#### 🎯 핵심 기능

1. **시크릿 관리 (Secrets Management)**
   - 데이터베이스 자격 증명
   - API 키 및 토큰
   - SSH 키 및 인증서
   - 클라우드 서비스 자격 증명

2. **암호화 서비스 (Encryption as a Service)**
   - 데이터 암호화/복호화
   - 키 관리 및 회전
   - HSM(Hardware Security Module) 통합

3. **권한 관리 (Privileged Access Management)**
   - 동적 시크릿 생성
   - 임시 자격 증명 발급
   - 세션 관리 및 감사

4. **인증 및 권한 부여 (Authentication & Authorization)**
   - 다양한 인증 방법 지원
   - 정책 기반 접근 제어
   - 역할 기반 권한 관리

### 🏛️ Vault 아키텍처

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Vault Client  │    │   Vault Server  │    │ Storage Backend │
│                 │    │                 │    │                 │
│ • CLI           │◄──►│ • API Server    │◄──►│ • Consul        │
│ • SDK           │    │ • Core Engine   │    │ • etcd          │
│ • Web UI        │    │ • Auth Methods  │    │ • Raft          │
│ • Agent         │    │ • Secret Engines│    │ • Database      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

#### 🔧 핵심 구성 요소

1. **Vault Server**
   - HTTP API 서버
   - 인증 및 권한 부여 엔진
   - 시크릿 엔진
   - 감사 로그 시스템

2. **Storage Backend**
   - Consul (분산 키-값 저장소)
   - etcd (분산 구성 저장소)
   - Raft (내장 분산 합의)
   - 데이터베이스 (PostgreSQL, MySQL 등)

3. **Authentication Methods**
   - Token 기반 인증
   - Kubernetes 인증
   - LDAP/Active Directory
   - OIDC/JWT
   - AWS IAM

### 🆚 다른 솔루션과의 비교

#### AWS Secrets Manager vs Vault

| 기능 | AWS Secrets Manager | HashiCorp Vault |
|------|-------------------|------------------|
| **가격** | 사용량 기반 과금 | Self-Hosted 무료 |
| **클라우드 종속성** | AWS 전용 | 멀티 클라우드 |
| **기능 범위** | 시크릿 관리 중심 | 시크릿 + 암호화 + 권한 관리 |
| **통합성** | AWS 서비스와 긴밀 | 다양한 플랫폼 지원 |
| **확장성** | AWS 한계 내 | 무제한 확장 |

#### Azure Key Vault vs Vault

| 기능 | Azure Key Vault | HashiCorp Vault |
|------|-----------------|------------------|
| **가격** | 사용량 기반 과금 | Self-Hosted 무료 |
| **클라우드 종속성** | Azure 전용 | 멀티 클라우드 |
| **키 관리** | HSM 통합 우수 | 다양한 백엔드 지원 |
| **개발자 경험** | Azure 생태계 중심 | 플랫폼 독립적 |
| **오픈소스** | 부분적 | 완전 오픈소스 |

#### Kubernetes Secrets vs Vault

| 기능 | Kubernetes Secrets | HashiCorp Vault |
|------|-------------------|------------------|
| **암호화** | 기본 암호화만 | 강력한 암호화 |
| **동적 시크릿** | 지원 안함 | 완전 지원 |
| **감사 로그** | 제한적 | 상세한 감사 |
| **정책 관리** | RBAC만 | 세밀한 정책 |
| **자동 회전** | 수동만 | 자동화 지원 |

### 🌟 Vault의 우수한 점

1. **플랫폼 독립성**
   - 클라우드 벤더 종속성 없음
   - 온프레미스, 하이브리드, 멀티 클라우드 지원

2. **강력한 보안 기능**
   - Zero Trust 아키텍처
   - 세밀한 접근 제어
   - 상세한 감사 로그

3. **개발자 친화적**
   - RESTful API
   - 다양한 SDK 지원
   - CLI 도구 제공

4. **확장성과 성능**
   - 수평적 확장 가능
   - 고가용성 지원
   - 성능 최적화

5. **생태계 통합**
   - Kubernetes 네이티브
   - CI/CD 파이프라인 통합
   - 모니터링 도구 연동

---

## 🚀 Kubernetes 클러스터에 Vault 배포

### 📋 사전 요구사항

#### 🛠️ 필수 도구

```bash
# Kubernetes 클러스터 (minikube, kind, 또는 실제 클러스터)
kubectl version --client

# Helm (패키지 매니저)
helm version

# Vault CLI
brew install vault  # macOS
# 또는
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install vault
```

#### 🔧 시스템 요구사항

- **CPU**: 최소 2코어, 권장 4코어 이상
- **메모리**: 최소 2GB, 권장 8GB 이상
- **스토리지**: 최소 10GB, 권장 50GB 이상
- **네트워크**: 클러스터 내 통신 가능

### 🎯 배포 전략

#### 1️⃣ 단일 인스턴스 배포 (개발/테스트)

```yaml
# vault-single.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: vault
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vault
  namespace: vault
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vault
  template:
    metadata:
      labels:
        app: vault
    spec:
      containers:
      - name: vault
        image: hashicorp/vault:latest
        ports:
        - containerPort: 8200
        env:
        - name: VAULT_DEV_ROOT_TOKEN_ID
          value: "dev-token"
        - name: VAULT_DEV_LISTEN_ADDRESS
          value: "0.0.0.0:8200"
        - name: VAULT_DEV_TLS_DISABLE
          value: "true"
        command:
        - vault
        - server
        - -dev
        - -dev-root-token-id=dev-token
        - -dev-listen-address=0.0.0.0:8200
```

#### 2️⃣ 고가용성 배포 (프로덕션)

```yaml
# vault-ha.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: vault
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vault
  namespace: vault
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: vault-server-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: vault
  namespace: vault
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: vault
  namespace: vault
spec:
  serviceName: vault
  replicas: 3
  selector:
    matchLabels:
      app: vault
  template:
    metadata:
      labels:
        app: vault
    spec:
      serviceAccountName: vault
      containers:
      - name: vault
        image: hashicorp/vault:latest
        ports:
        - containerPort: 8200
        env:
        - name: VAULT_CACERT
          value: "/vault/userconfig/vault-ha-tls/vault.ca"
        - name: VAULT_SKIP_VERIFY
          value: "false"
        volumeMounts:
        - name: vault-config
          mountPath: /vault/config
        - name: vault-ha-tls
          mountPath: /vault/userconfig/vault-ha-tls
          readOnly: true
        - name: vault-data
          mountPath: /vault/file
        command:
        - vault
        - server
        - -config=/vault/config/vault.json
      volumes:
      - name: vault-config
        configMap:
          name: vault-config
      - name: vault-ha-tls
        secret:
          secretName: vault-ha-tls
  volumeClaimTemplates:
  - metadata:
      name: vault-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

### 🔧 Vault 설정 파일

#### 📝 ConfigMap 생성

```yaml
# vault-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: vault-config
  namespace: vault
data:
  vault.json: |
    {
      "storage": {
        "file": {
          "path": "/vault/file"
        }
      },
      "listener": {
        "tcp": {
          "address": "0.0.0.0:8200",
          "tls_disable": true
        }
      },
      "ui": true,
      "disable_mlock": true
    }
```

#### 🔐 TLS 인증서 생성

```bash
# TLS 인증서 생성 스크립트
#!/bin/bash

# Vault 네임스페이스 생성
kubectl create namespace vault

# 인증서 디렉토리 생성
mkdir -p vault-certs

# CA 인증서 생성
openssl genrsa -out vault-certs/ca.key 2048
openssl req -new -x509 -key vault-certs/ca.key -out vault-certs/ca.crt -days 365 \
  -subj "/C=KR/ST=Seoul/L=Seoul/O=Vault/CN=vault-ca"

# 서버 인증서 생성
openssl genrsa -out vault-certs/server.key 2048
openssl req -new -key vault-certs/server.key -out vault-certs/server.csr \
  -subj "/C=KR/ST=Seoul/L=Seoul/O=Vault/CN=vault.default.svc.cluster.local"

# 서버 인증서 서명
openssl x509 -req -in vault-certs/server.csr -CA vault-certs/ca.crt \
  -CAkey vault-certs/ca.key -CAcreateserial -out vault-certs/server.crt -days 365

# Kubernetes Secret 생성
kubectl create secret generic vault-ha-tls \
  --from-file=vault.ca=vault-certs/ca.crt \
  --from-file=vault.crt=vault-certs/server.crt \
  --from-file=vault.key=vault-certs/server.key \
  -n vault
```

### 🚀 Helm을 사용한 배포

#### 📦 Helm Repository 추가

```bash
# HashiCorp Helm Repository 추가
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# 사용 가능한 차트 확인
helm search repo hashicorp/vault
```

#### ⚙️ Helm Values 설정

```yaml
# vault-values.yaml
global:
  enabled: true
  tlsDisable: false

server:
  enabled: true
  replicas: 3

  # 스토리지 설정
  dataStorage:
    size: 10Gi
    storageClass: ""

  # 리소스 설정
  resources:
    requests:
      memory: "256Mi"
      cpu: "250m"
    limits:
      memory: "512Mi"
      cpu: "500m"

  # 서비스 설정
  service:
    enabled: true
    type: ClusterIP

  # UI 설정
  ui:
    enabled: true

  # 인증서 설정
  extraEnvironmentVars:
    VAULT_CACERT: /vault/userconfig/vault-ha-tls/vault.ca
    VAULT_SKIP_VERIFY: "false"

  # 볼륨 마운트
  extraVolumes:
    - type: secret
      name: vault-ha-tls
      path: /vault/userconfig/vault-ha-tls
      readOnly: true

  # 컨테이너 볼륨 마운트
  extraVolumeMounts:
    - name: vault-ha-tls
      mountPath: /vault/userconfig/vault-ha-tls
      readOnly: true
```

#### 🚀 Helm 배포 실행

```bash
# Helm으로 Vault 배포
helm install vault hashicorp/vault \
  --namespace vault \
  --create-namespace \
  --values vault-values.yaml

# 배포 상태 확인
kubectl get pods -n vault
kubectl get svc -n vault

# Vault 초기화
kubectl exec -n vault vault-0 -- vault operator init \
  -key-shares=5 \
  -key-threshold=3 \
  -format=json > vault-keys.json

# 루트 토큰 추출
ROOT_TOKEN=$(jq -r '.root_token' vault-keys.json)
echo "Root Token: $ROOT_TOKEN"

# Vault 로그인
kubectl exec -n vault vault-0 -- vault login $ROOT_TOKEN
```

### 🔍 배포 확인

#### 📊 상태 확인 명령어

```bash
# Pod 상태 확인
kubectl get pods -n vault -o wide

# 서비스 확인
kubectl get svc -n vault

# 로그 확인
kubectl logs -n vault vault-0

# Vault 상태 확인
kubectl exec -n vault vault-0 -- vault status

# 포트 포워딩으로 UI 접근
kubectl port-forward -n vault svc/vault 8200:8200
```

#### 🌐 웹 UI 접근

브라우저에서 `http://localhost:8200`으로 접근하여 Vault 웹 UI를 사용할 수 있습니다.

---

## ⚙️ Vault 운영 및 모니터링

### 🔧 초기 설정

#### 1️⃣ Vault 초기화

```bash
# Vault 초기화 (개발 모드)
kubectl exec -n vault vault-0 -- vault operator init \
  -key-shares=5 \
  -key-threshold=3 \
  -format=json > vault-keys.json

# 키 정보 확인
cat vault-keys.json | jq '.'

# 루트 토큰 추출
ROOT_TOKEN=$(jq -r '.root_token' vault-keys.json)
echo "Root Token: $ROOT_TOKEN"

# Vault 로그인
kubectl exec -n vault vault-0 -- vault login $ROOT_TOKEN
```

#### 2️⃣ 인증 방법 설정

```bash
# Kubernetes 인증 활성화
kubectl exec -n vault vault-0 -- vault auth enable kubernetes

# Kubernetes 인증 설정
kubectl exec -n vault vault-0 -- vault write auth/kubernetes/config \
  kubernetes_host="https://kubernetes.default.svc.cluster.local" \
  kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  token_reviewer_jwt=@/var/run/secrets/kubernetes.io/serviceaccount/token

# 정책 생성
kubectl exec -n vault vault-0 -- vault policy write myapp-policy - <<EOF
path "secret/data/myapp/*" {
  capabilities = ["read"]
}
EOF

# Kubernetes 역할 생성
kubectl exec -n vault vault-0 -- vault write auth/kubernetes/role/myapp \
  bound_service_account_names=myapp \
  bound_service_account_namespaces=default \
  policies=myapp-policy \
  ttl=1h
```

### 📊 모니터링 설정

#### 🔍 Prometheus 메트릭 활성화

```bash
# Vault 메트릭 활성화
kubectl exec -n vault vault-0 -- vault write sys/config/telemetry \
  telemetry {
    prometheus_retention_time = "24h"
    disable_hostname = true
  }
```

#### 📈 Grafana 대시보드

```yaml
# vault-grafana-dashboard.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: vault-dashboard
  namespace: monitoring
data:
  vault-dashboard.json: |
    {
      "dashboard": {
        "title": "Vault Dashboard",
        "panels": [
          {
            "title": "Vault Status",
            "type": "stat",
            "targets": [
              {
                "expr": "vault_core_unsealed{job=\"vault\"}",
                "legendFormat": "Unsealed"
              }
            ]
          },
          {
            "title": "Token Creation Rate",
            "type": "graph",
            "targets": [
              {
                "expr": "rate(vault_token_create{job=\"vault\"}[5m])",
                "legendFormat": "Token Creation Rate"
              }
            ]
          }
        ]
      }
    }
```

### 🔐 시크릿 엔진 설정

#### 1️⃣ KV 시크릿 엔진

```bash
# KV v2 시크릿 엔진 활성화
kubectl exec -n vault vault-0 -- vault secrets enable -path=secret kv-v2

# 시크릿 저장
kubectl exec -n vault vault-0 -- vault kv put secret/myapp/database \
  username=admin \
  password=secretpassword123

# 시크릿 조회
kubectl exec -n vault vault-0 -- vault kv get secret/myapp/database
```

#### 2️⃣ 데이터베이스 시크릿 엔진

```bash
# 데이터베이스 시크릿 엔진 활성화
kubectl exec -n vault vault-0 -- vault secrets enable database

# PostgreSQL 연결 설정
kubectl exec -n vault vault-0 -- vault write database/config/postgresql \
  plugin_name=postgresql-database-plugin \
  allowed_roles="myapp-role" \
  connection_url="postgresql://{{username}}:{{password}}@postgresql:5432/myapp?sslmode=disable" \
  username="vault" \
  password="vaultpassword"

# 데이터베이스 역할 생성
kubectl exec -n vault vault-0 -- vault write database/roles/myapp-role \
  db_name=postgresql \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl=1h \
  max_ttl=24h
```

### 🔄 자동화 및 CI/CD 통합

#### 📝 Kubernetes Secret 동기화

```yaml
# vault-agent-injector.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/agent-inject-secret-database: "secret/data/myapp/database"
        vault.hashicorp.com/role: "myapp"
    spec:
      serviceAccountName: myapp
      containers:
      - name: myapp
        image: nginx:alpine
        ports:
        - containerPort: 80
```

#### 🔧 Vault Agent 설정

```yaml
# vault-agent-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: vault-agent-config
  namespace: default
data:
  vault-agent-config.hcl: |
    exit_after_auth = true
    pid_file = "/home/vault/pidfile"

    auto_auth {
      method "kubernetes" {
        mount_path = "auth/kubernetes"
        role = "myapp"
      }
    }

    template {
      destination = "/vault/secrets/database"
      contents = <<EOH
      {% raw %}{{ with secret "secret/data/myapp/database" }}{% endraw %}
      DATABASE_USERNAME={% raw %}{{ .Data.data.username }}{% endraw %}
      DATABASE_PASSWORD={% raw %}{{ .Data.data.password }}{% endraw %}
      {% raw %}{{ end }}{% endraw %}
      EOH
    }
```

### 🛡️ 보안 모범 사례

#### 1️⃣ 네트워크 보안

```yaml
# vault-network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: vault-network-policy
  namespace: vault
spec:
  podSelector:
    matchLabels:
      app: vault
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: vault
    ports:
    - protocol: TCP
      port: 8200
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: TCP
      port: 443
```

#### 2️⃣ RBAC 설정

```yaml
# vault-rbac.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: vault-server
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["*"]
- apiGroups: [""]
  resources: ["serviceaccounts"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: vault-server-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: vault-server
subjects:
- kind: ServiceAccount
  name: vault
  namespace: vault
```

### 📊 백업 및 복구

#### 💾 백업 스크립트

```bash
#!/bin/bash
# vault-backup.sh

NAMESPACE="vault"
BACKUP_DIR="/backup/vault"
DATE=$(date +%Y%m%d_%H%M%S)

# 백업 디렉토리 생성
mkdir -p $BACKUP_DIR

# Vault 설정 백업
kubectl get configmap -n $NAMESPACE -o yaml > $BACKUP_DIR/configmap_$DATE.yaml
kubectl get secret -n $NAMESPACE -o yaml > $BACKUP_DIR/secret_$DATE.yaml

# PVC 스냅샷 생성
kubectl get pvc -n $NAMESPACE -o name | while read pvc; do
  kubectl exec -n $NAMESPACE vault-0 -- vault operator raft snapshot save /tmp/snapshot.snap
  kubectl cp $NAMESPACE/vault-0:/tmp/snapshot.snap $BACKUP_DIR/snapshot_$DATE.snap
done

echo "Vault backup completed: $BACKUP_DIR"
```

#### 🔄 복구 스크립트

```bash
#!/bin/bash
# vault-restore.sh

NAMESPACE="vault"
BACKUP_DIR="/backup/vault"
BACKUP_DATE=$1

if [ -z "$BACKUP_DATE" ]; then
  echo "Usage: $0 <backup_date>"
  exit 1
fi

# Vault 중지
kubectl scale deployment vault -n $NAMESPACE --replicas=0

# 설정 복구
kubectl apply -f $BACKUP_DIR/configmap_$BACKUP_DATE.yaml
kubectl apply -f $BACKUP_DIR/secret_$BACKUP_DATE.yaml

# 스냅샷 복구
kubectl cp $BACKUP_DIR/snapshot_$BACKUP_DATE.snap $NAMESPACE/vault-0:/tmp/snapshot.snap
kubectl exec -n $NAMESPACE vault-0 -- vault operator raft snapshot restore /tmp/snapshot.snap

# Vault 재시작
kubectl scale deployment vault -n $NAMESPACE --replicas=3

echo "Vault restore completed"
```

---

## 🎯 실제 사용 사례

### 📱 웹 애플리케이션 시크릿 관리

#### 1️⃣ 애플리케이션 배포

```yaml
# myapp-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/agent-inject-secret-database: "secret/data/myapp/database"
        vault.hashicorp.com/agent-inject-secret-api: "secret/data/myapp/api"
        vault.hashicorp.com/role: "myapp"
    spec:
      serviceAccountName: myapp
      containers:
      - name: myapp
        image: myapp:latest
        ports:
        - containerPort: 8080
        env:
        - name: DATABASE_URL
          value: "file:///vault/secrets/database"
        - name: API_KEY
          value: "file:///vault/secrets/api"
```

#### 2️⃣ 시크릿 저장

```bash
# 데이터베이스 시크릿 저장
kubectl exec -n vault vault-0 -- vault kv put secret/myapp/database \
  host=postgresql.default.svc.cluster.local \
  port=5432 \
  database=myapp \
  username=myapp_user \
  password=secure_password_123

# API 키 저장
kubectl exec -n vault vault-0 -- vault kv put secret/myapp/api \
  api_key=sk-1234567890abcdef \
  api_secret=secret_key_abcdef123456
```

### 🔐 마이크로서비스 인증

#### 1️⃣ 서비스 간 인증 설정

```bash
# JWT 인증 활성화
kubectl exec -n vault vault-0 -- vault auth enable jwt

# JWT 설정
kubectl exec -n vault vault-0 -- vault write auth/jwt/config \
  oidc_discovery_url="https://accounts.google.com" \
  bound_issuer="https://accounts.google.com"

# 서비스 역할 생성
kubectl exec -n vault vault-0 -- vault write auth/jwt/role/service-a \
  role_type="jwt" \
  bound_audiences="myapp" \
  user_claim="sub" \
  policies="service-a-policy"
```

#### 2️⃣ 정책 정의

```bash
# 서비스 A 정책
kubectl exec -n vault vault-0 -- vault policy write service-a-policy - <<EOF
path "secret/data/service-a/*" {
  capabilities = ["read"]
}

path "auth/token/create" {
  capabilities = ["create", "update"]
}
EOF
```

### 🔄 동적 시크릿 생성

#### 1️⃣ 데이터베이스 동적 시크릿

```bash
# PostgreSQL 동적 시크릿 설정
kubectl exec -n vault vault-0 -- vault write database/config/postgresql \
  plugin_name=postgresql-database-plugin \
  allowed_roles="app-role" \
  connection_url="postgresql://{{username}}:{{password}}@postgresql:5432/myapp?sslmode=disable" \
  username="vault" \
  password="vault_password"

# 역할 생성
kubectl exec -n vault vault-0 -- vault write database/roles/app-role \
  db_name=postgresql \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl=1h \
  max_ttl=24h
```

#### 2️⃣ 애플리케이션에서 사용

```python
# Python 예제
import hvac
import os

# Vault 클라이언트 설정
client = hvac.Client(
    url='http://vault:8200',
    token=os.environ.get('VAULT_TOKEN')
)

# 동적 데이터베이스 자격 증명 생성
response = client.secrets.database.generate_credentials(
    name='app-role'
)

# 데이터베이스 연결
import psycopg2
conn = psycopg2.connect(
    host=response['data']['host'],
    database=response['data']['database'],
    user=response['data']['username'],
    password=response['data']['password']
)
```

---

## 🎯 결론

HashiCorp Vault는 현대적인 클라우드 네이티브 환경에서 시크릿 관리와 보안을 위한 강력한 솔루션입니다. 이 튜토리얼을 통해 Vault의 핵심 개념을 이해하고, Kubernetes 클러스터에 Self-Hosted로 배포하여 운영하는 방법을 학습했습니다.

### 🏆 주요 학습 내용

1. **Vault 아키텍처 이해**: 시크릿 관리, 암호화 서비스, 권한 관리의 통합 플랫폼
2. **다른 솔루션과의 비교**: AWS Secrets Manager, Azure Key Vault, Kubernetes Secrets 대비 우수성
3. **Kubernetes 배포**: Helm을 사용한 고가용성 배포 및 설정
4. **운영 및 모니터링**: Prometheus 메트릭, Grafana 대시보드, 백업/복구
5. **실제 사용 사례**: 웹 애플리케이션, 마이크로서비스, 동적 시크릿 생성

### 🚀 다음 단계

Vault를 성공적으로 배포한 후에는 다음 단계를 고려해보세요:

1. **고급 인증 방법 구현**: OIDC, LDAP, AWS IAM 통합
2. **암호화 서비스 활용**: 데이터 암호화/복호화, 키 관리
3. **CI/CD 파이프라인 통합**: Jenkins, GitLab CI, GitHub Actions 연동
4. **다중 클러스터 설정**: Vault 클러스터 간 복제 및 DR 설정
5. **성능 최적화**: 캐싱, 연결 풀링, 리소스 튜닝

### 📚 추가 학습 자료

- [HashiCorp Vault 공식 문서](https://developer.hashicorp.com/vault)
- [Vault GitHub 저장소](https://github.com/hashicorp/vault)
- [Vault Kubernetes 연동 가이드](https://developer.hashicorp.com/vault/docs/platform/k8s)
- [Vault 모범 사례](https://developer.hashicorp.com/vault/docs/best-practices)

Vault를 통해 조직의 보안 수준을 크게 향상시키고, 개발자 경험을 개선할 수 있습니다. 지속적인 학습과 실습을 통해 Vault의 모든 잠재력을 활용해보세요! 🔐✨
