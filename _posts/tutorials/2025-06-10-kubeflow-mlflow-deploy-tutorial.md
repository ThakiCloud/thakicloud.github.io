---
title: "Kubernetes 환경에서 KubeFlow와 MLFlow 구축 가이드"
date: 2025-06-10
categories: 
  - MLOps
  - Kubernetes
  - tutorials
tags: 
  - kubeflow
  - mlflow
  - kubernetes
  - mlops
  - istio
  - tutorial
author_profile: true
toc: true
toc_label: "구축 가이드"
---

Kubernetes 환경에서 KubeFlow와 MLFlow를 구축하는 방법을 단계별로 알아보겠습니다.

## 사전 준비사항

다음 환경과 도구들이 준비되어 있는지 먼저 확인해주세요:

- **Kubernetes 클러스터** 1.33 버전
- **Git** 설치
- **macOS** 환경 (다른 OS도 가능하나 명령어가 다를 수 있음)
- **최소 8GB RAM** 권장 (16GB 이상 권장)
- **20GB 이상 디스크 공간**

## Istio 서비스 메시 설치

KubeFlow는 마이크로서비스 아키텍처를 기반으로 하며, 서비스 간 통신을 위해 Istio 서비스 메시가 필요합니다. 먼저 Istio를 설치해보겠습니다.

### Istio 다운로드 및 설치

```bash
# Istio 최신 버전 다운로드
curl -L https://istio.io/downloadIstio | sh -

# Istio 디렉토리로 이동
cd istio-*/bin

# Istio 버전 확인
./istioctl version
```

### 클러스터에 Istio 배포

```bash
# Istio 기본 프로필로 설치
./istioctl install --set profile=default

# 설치 상태 확인
kubectl get pods -n istio-system
```

정상적으로 설치되었다면 다음과 같은 결과를 확인할 수 있습니다:

```
NAME                                   READY   STATUS    RESTARTS   AGE
istio-ingressgateway-xxx               1/1     Running   0          2m
istiod-xxx                            1/1     Running   0          2m
```

### Istio 설치 검증

```bash
# Istio 서비스 상태 확인
kubectl get svc -n istio-system

# Istio 게이트웨이 확인
kubectl get gateway -A
```

## KubeFlow 플랫폼 구축

### 필수 도구 설치

KubeFlow 설치를 위해 필요한 도구들을 먼저 설치합니다:

```bash
# kubectl 설치 (Kubernetes 클라이언트)
brew install kubectl

# kustomize 설치 (Kubernetes 매니페스트 관리 도구)
brew install kustomize

# 설치 확인
kubectl version --client
kustomize version
```

### KubeFlow 매니페스트 준비

```bash
# KubeFlow 공식 매니페스트 레포지토리 클론
git clone https://github.com/kubeflow/manifests.git

# 매니페스트 디렉토리로 이동
cd manifests
```

### KubeFlow 구성 요소 배포

```bash
# KubeFlow 모든 구성 요소 배포
sudo kustomize build example | kubectl apply -f -

# 배포 진행 상황 모니터링
kubectl get pods -n kubeflow
```

배포 과정에서 여러 파드들이 순차적으로 생성되며, 모든 파드가 Running 상태가 될 때까지 5-10분 정도 소요됩니다.

### KubeFlow 서비스 확인 및 접속

```bash
# KubeFlow 서비스 상태 확인
kubectl get svc -n kubeflow

# 웹 인터페이스 접속을 위한 포트 포워딩
kubectl port-forward svc/istio-ingressgateway -n istio-system 8888:80
```

이제 브라우저에서 `http://localhost:8888`로 접속하여 KubeFlow 대시보드에 로그인할 수 있습니다:

- **사용자명**: `user@example.com`
- **비밀번호**: `12341234`

## MLFlow 구성

### MLFlow 전용 환경 준비

MLFlow를 독립적으로 관리하기 위해 별도의 네임스페이스를 생성합니다:

```bash
# MLFlow 시스템용 네임스페이스 생성
kubectl create ns mlflow-system

# 네임스페이스 생성 확인
kubectl get ns | grep mlflow
```

### PostgreSQL 메타데이터 저장소 설치

```bash
# PostgreSQL 매니페스트 적용
kubectl -n mlflow-system apply -f https://raw.githubusercontent.com/mlops-for-all/helm-charts/b94b5fe4133f769c04b25068b98ccfa7a505aa60/mlflow/manifests/postgres.yaml

# PostgreSQL 파드 상태 확인
kubectl get pods -n mlflow-system
```

### Helm 패키지 관리자 설정

```bash
# MLOps-for-All Helm 저장소 추가
helm repo add mlops-for-all https://mlops-for-all.github.io/helm-charts

# Helm 저장소 업데이트
helm repo update
```

### MinIO 객체 스토리지 구성

KubeFlow에 포함된 MinIO를 MLFlow의 아티팩트 저장소로 활용합니다:

```bash
# MinIO 웹 콘솔 접속을 위한 포트 포워딩
kubectl port-forward -n kubeflow svc/minio-service 9000:9000
```

브라우저에서 `http://localhost:9000`으로 MinIO 웹 콘솔에 접속합니다:

- **사용자명**: `minio`
- **비밀번호**: `minio123`

MinIO 콘솔에서 다음 버킷들을 생성해주세요:

- `mlflow-artifacts`: MLFlow 모델 및 아티팩트 저장
- `kubeflow-pipelines`: KubeFlow 파이프라인 아티팩트 저장

### MLFlow 서버 배포

```bash
# MLFlow 서버 Helm 차트를 통한 설치
helm install mlflow-server mlops-for-all/mlflow-server \
  --namespace mlflow-system \
  --version 0.2.0

# MLFlow 서버 배포 상태 확인
kubectl get pods -n mlflow-system
kubectl get svc -n mlflow-system
```

### MLFlow 웹 인터페이스 접속

```bash
# MLFlow 트래킹 서버 포트 포워딩
kubectl port-forward svc/mlflow-server-service -n mlflow-system 5050:5000
```

브라우저에서 `http://localhost:5050`으로 MLFlow 트래킹 서버에 접속할 수 있습니다.

## MLFlow vs KubeFlow 비교 분석

두 플랫폼 모두 MLOps 생태계의 핵심 구성 요소이지만, 각각 다른 역할과 강점을 가지고 있습니다.

### KubeFlow의 장단점

**장점:**
- **완전한 ML 워크플로우 오케스트레이션**: 데이터 전처리부터 모델 배포까지 전체 파이프라인 관리
- **Kubernetes 네이티브**: 클라우드 환경에서의 확장성과 안정성 제공
- **다양한 ML 프레임워크 지원**: TensorFlow, PyTorch, Scikit-learn 등 광범위한 지원
- **Jupyter 노트북 통합**: 웹 기반 개발 환경 제공
- **하이퍼파라미터 튜닝**: Katib을 통한 자동화된 하이퍼파라미터 최적화

**단점:**
- **높은 복잡성**: 설치 및 관리가 복잡하고 Kubernetes 전문 지식 필요
- **리소스 집약적**: 많은 메모리와 CPU 리소스 소비
- **러닝 커브**: 초기 학습 비용이 높음
- **의존성 관리**: 다양한 구성 요소 간 버전 호환성 문제 가능성

### MLFlow의 장단점

**장점:**
- **단순함과 직관성**: 빠른 설치와 쉬운 사용법
- **실험 추적 특화**: 매개변수, 메트릭, 아티팩트 체계적 관리
- **모델 레지스트리**: 중앙화된 모델 버전 관리 및 배포
- **언어 독립적**: Python, R, Java, Scala 등 다양한 언어 지원
- **가벼운 아키텍처**: 최소한의 리소스로 운영 가능

**단점:**
- **제한적인 워크플로우 관리**: 복잡한 파이프라인 오케스트레이션 부족
- **스케일링 한계**: 대규모 분산 처리에 제약
- **UI 기능 제한**: 기본적인 실험 추적 인터페이스만 제공
- **고급 기능 부족**: 하이퍼파라미터 튜닝, A/B 테스트 등 고급 기능 미흡

## 문제 해결 가이드

### JWT 인증 에러 해결

KubeFlow 대시보드 접속 시 다음과 같은 에러가 발생할 수 있습니다:

```
Jwks doesnt have key to match kid or alg from Jwt
```

### 해결 방법

**1단계: 브라우저 쿠키 삭제**

Chrome/Safari 브라우저의 경우:
1. 개발자 도구 열기 (`F12` 또는 `Cmd+Option+I`)
2. **Application** 탭으로 이동
3. 왼쪽 메뉴에서 **Storage > Cookies** 선택
4. `localhost:8888` 또는 KubeFlow 접속 URL 선택
5. 모든 쿠키 항목 선택 후 삭제

**2단계: 브라우저 캐시 정리**

```bash
# 브라우저를 완전히 종료 후 재시작
# 또는 시크릿/프라이빗 모드로 접속 시도
```
## 결론

본 가이드를 통해 Kubernetes 환경에서 KubeFlow와 MLFlow를 성공적으로 구축했습니다.

### 구축된 MLOps 아키텍처

**핵심 구성 요소:**
- **KubeFlow**: 파이프라인 오케스트레이션 및 워크플로우 자동화
- **MLFlow**: 실험 추적 및 모델 레지스트리 관리  
- **Istio**: 마이크로서비스 통신 보안 및 트래픽 관리
- **MinIO**: S3 호환 객체 스토리지
- **PostgreSQL**: 메타데이터 및 실험 이력 저장

---

**참고 링크:**
- [KubeFlow 공식 문서](https://www.kubeflow.org/docs/)
- [MLFlow 공식 문서](https://mlflow.org/docs/latest/index.html)
- [Istio 공식 문서](https://istio.io/latest/docs/)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/home/) 