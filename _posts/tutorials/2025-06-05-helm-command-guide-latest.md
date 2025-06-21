---
title: "Helm 최신 명령어 가이드 - 쿠버네티스 패키지 관리자 완전 정복"
date: 2025-06-05
categories: 
  - Kubernetes
  - DevOps
  - tutorials
tags: 
  - Helm
  - Kubernetes
  - 쿠버네티스
  - 패키지 관리
  - DevOps
  - 차트
author_profile: true
toc: true
toc_label: Helm 명령어 가이드
---

Helm은 쿠버네티스를 위한 패키지 관리자로, 복잡한 애플리케이션을 쉽게 배포하고 관리할 수 있게 해주는 강력한 도구입니다. 이 가이드에서는 Helm의 최신 명령어들을 체계적으로 정리하여 실무에서 바로 활용할 수 있도록 안내해드리겠습니다.

## Helm 설치하기

먼저 Helm을 설치하는 여러 가지 방법을 알아보겠습니다.

### 공식 스크립트를 사용한 설치

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

### macOS에서 Homebrew로 설치

```bash
brew install helm
```

### Snap을 사용한 설치

```bash
sudo snap install helm --classic
```

## 기본 Helm 명령어

### 도움말 보기

Helm의 모든 명령어와 옵션을 확인할 수 있습니다.

```bash
helm help
```

특정 명령어의 도움말을 보려면:

```bash
helm get -h
```

## 차트 저장소 관리

Helm은 차트 저장소를 통해 사전 구성된 애플리케이션 패키지를 제공합니다.

### 저장소 추가

```bash
helm repo add [NAME] [URL] [flags]
```

실제 예시:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

### 저장소 목록 확인

```bash
helm repo list
```

### 저장소 업데이트

로컬 저장소 인덱스를 최신 상태로 업데이트합니다.

```bash
helm repo update
```

### 저장소 제거

```bash
helm repo remove <repo_name>
```

### 차트 검색

저장소에서 차트를 검색합니다.

```bash
helm search repo <keyword>
```

예시:

```bash
helm search repo bitnami
```

Artifact Hub에서 공개적으로 사용 가능한 차트를 검색:

```bash
helm search hub <keyword>
```

## 차트 관리 명령어

### 새 차트 생성

```bash
helm create <name>
```

예시:

```bash
helm create mychart
```

### 차트 패키징

차트를 버전화된 아카이브 파일로 패키징합니다.

```bash
helm package <chart-path>
```

### 차트 검증

차트를 검사하고 잠재적인 문제를 식별합니다.

```bash
helm lint <chart>
```

### 차트 정보 확인

차트의 내용과 정보를 확인합니다.

```bash
helm show all <chart>
helm show values <chart>
```

### 차트 다운로드

```bash
helm pull <chart>
helm pull <chart> --untar=true
helm pull <chart> --verify
helm pull <chart> --version <number>
```

### 의존성 관리

차트의 의존성 목록을 표시합니다.

```bash
helm dependency list <chart>
```

## 릴리스 설치 및 관리

### 차트 설치

기본 설치 구문:

```bash
helm install [NAME] [CHART] [flags]
```

실제 예시:

```bash
helm install happy-panda bitnami/wordpress
```

자동 이름 생성으로 설치:

```bash
helm install bitnami/mysql --generate-name
```

### 중요한 설치 옵션들

#### 값 설정

```bash
# 명령행에서 값 설정
helm install --set key1=val1,key2=val2 myapp ./chart

# 파일에서 값 설정
helm install -f values.yaml myapp ./chart

# 문자열 값 설정
helm install --set-string long_int=1234567890 myredis ./redis

# 파일에서 값 설정
helm install --set-file my_script=dothings.sh myredis ./redis
```

#### 네임스페이스 및 기타 옵션

```bash
helm install myapp ./chart \
  --create-namespace \
  --namespace production \
  --wait \
  --timeout 10m \
  --atomic
```

### 드라이런 및 디버그

실제 설치 없이 렌더링된 템플릿을 확인:

```bash
helm install --debug --dry-run goodly-guppy ./mychart
```

### 릴리스 목록 확인

```bash
helm list [flags]
```

### 릴리스 상태 확인

```bash
helm status <release-name>
```

### 릴리스 업그레이드

```bash
helm upgrade <release> <chart>
```

업그레이드 옵션들:

```bash
helm upgrade <release> <chart> --atomic
helm upgrade <release> <chart> --dependency-update
helm upgrade <release> <chart> --version <version_number>
helm upgrade <release> <chart> --values values.yaml
helm upgrade <release> <chart> --set key1=val1,key2=val2
helm upgrade <release> <chart> --force
```

### 설치 또는 업그레이드

릴리스가 존재하지 않으면 설치하고, 존재하면 업그레이드합니다.

```bash
helm upgrade --install <release name> --values <values file> <chart directory>
```

### 릴리스 롤백

```bash
helm rollback <release> <revision>
helm rollback <release> <revision> --cleanup-on-fail
```

### 릴리스 값 확인

```bash
helm get values <release-name>
helm get values <release-name> --all
helm get values <release-name> --revision <number>
```

### 릴리스 제거

```bash
helm uninstall RELEASE_NAME [...] [flags]
```

예시:

```bash
helm uninstall mysql-1612624192
```

## 템플릿 명령어

### 템플릿 렌더링

로컬에서 차트 템플릿을 렌더링합니다.

```bash
helm template [NAME] [CHART] [flags]
```

### 템플릿 검증

```bash
helm template myapp ./chart --validate
```

### 특정 템플릿만 출력

```bash
helm template myapp ./chart --show-only templates/deployment.yaml
```

## 테스트 명령어

### 차트 테스트 실행

```bash
helm test <release-name>
```

예시:

```bash
helm install demo demo --namespace default
helm test demo
```

## 플러그인 관리

### 플러그인 설치

```bash
helm plugin install <path|url> [flags]
```

### 플러그인 제거

```bash
helm plugin uninstall <plugin>... [flags]
```

## 차트 저장소 고급 관리

### 저장소 인덱스 생성

```bash
helm repo index <DIR>
helm repo index <DIR> --merge  # 기존 인덱스와 병합
```

### 차트 푸시

원격 저장소에 차트를 푸시합니다.

```bash
helm push [chart] [remote] [flags]
```

## 자동 완성 설정

### Bash 자동 완성

현재 세션용:

```bash
source <(helm completion bash)
```

### Zsh 자동 완성

영구 설정:

```bash
helm completion zsh > "${fpath[1]}/_helm"
```

## 실전 예제 시나리오

### WordPress 설치 및 관리

1. **저장소 추가 및 업데이트**:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

2. **차트 정보 확인**:

```bash
helm show values bitnami/wordpress
```

3. **커스텀 값으로 설치**:

```bash
echo '{mariadb.auth.database: user0db, mariadb.auth.username: user0}' > values.yaml
helm install -f values.yaml my-wordpress bitnami/wordpress
```

4. **업그레이드**:

```bash
helm upgrade -f panda.yaml my-wordpress bitnami/wordpress
```

5. **상태 확인**:

```bash
helm status my-wordpress
helm get values my-wordpress
```

### 차트 개발 워크플로우

1. **새 차트 생성**:

```bash
helm create mychart
```

2. **차트 검증**:

```bash
helm lint ./mychart
```

3. **템플릿 테스트**:

```bash
helm template test-release ./mychart --debug --dry-run
```

4. **차트 설치 및 테스트**:

```bash
helm install test-release ./mychart
helm test test-release
```

## 고급 설정

### SQL 스토리지 백엔드 사용

```bash
export HELM_DRIVER=sql
export HELM_DRIVER_SQL_CONNECTION_STRING=postgresql://helm-postgres:5432/helm?user=helm&password=changeme
```

### RBAC 설정

클러스터 범위 접근을 위한 ClusterRoleBinding 생성:

```bash
kubectl create clusterrolebinding sam-view \
    --clusterrole view \
    --user sam

kubectl create clusterrolebinding sam-secret-reader \
    --clusterrole secret-reader \
    --user sam
```

## 마무리

이 가이드에서는 Helm의 핵심 명령어들을 체계적으로 정리했습니다. Helm을 효과적으로 사용하려면:

1. **기본 워크플로우 이해**: 저장소 추가 → 차트 검색 → 설치 → 관리
2. **값 관리**: `--set`, `-f values.yaml` 등을 활용한 유연한 설정
3. **릴리스 생명주기**: 설치, 업그레이드, 롤백, 제거의 전체 과정 숙지
4. **차트 개발**: `helm create`, `helm lint`, `helm template` 등을 활용한 개발 워크플로우

Helm은 쿠버네티스 환경에서 애플리케이션 배포와 관리를 크게 단순화해주는 강력한 도구입니다. 이 가이드의 명령어들을 참고하여 효율적인 쿠버네티스 운영을 경험해보시기 바랍니다.
