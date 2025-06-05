---
title: "쿠버네티스 최신 명령어 가이드 - kubectl로 마스터하는 컨테이너 오케스트레이션"
date: 2025-06-05
categories: 
  - Kubernetes
  - DevOps
  - Container
tags: 
  - Kubernetes
  - kubectl
  - 쿠버네티스
  - 컨테이너
  - DevOps
  - 오케스트레이션
author_profile: true
toc: true
toc_label: 쿠버네티스 명령어 가이드
---

쿠버네티스는 현대 클라우드 네이티브 애플리케이션의 핵심 플랫폼으로 자리잡았습니다. 이 가이드에서는 최신 kubectl 명령어들과 쿠버네티스의 핵심 기능들을 체계적으로 정리하여, 초보자부터 고급 사용자까지 모두가 실무에서 활용할 수 있도록 안내해드리겠습니다.

## kubectl 기본 설정

### kubectl 설치 및 설정

최신 kubectl을 설치하는 방법들입니다.

**macOS (Homebrew):**

```bash
brew install kubectl
```

**Linux:**

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### 클러스터 연결 설정

```bash
# 클러스터 정보 확인
kubectl cluster-info

# 컨텍스트 확인
kubectl config get-contexts

# 컨텍스트 전환
kubectl config use-context <context-name>

# 현재 컨텍스트 확인
kubectl config current-context
```

### kubectl 자동 완성 설정

**Bash:**

```bash
echo 'source <(kubectl completion bash)' >>~/.bashrc
```

**Zsh:**

```bash
echo 'source <(kubectl completion zsh)' >>~/.zshrc
```

## 기본 리소스 관리 명령어

### 파드(Pod) 관리

#### 파드 생성 및 조회

```bash
# 파드 생성
kubectl run nginx --image=nginx

# 파드 목록 조회
kubectl get pods

# 파드 상세 정보
kubectl describe pod nginx

# 파드 로그 확인
kubectl logs nginx

# 실시간 로그 확인
kubectl logs -f nginx

# 파드에 접속
kubectl exec -it nginx -- /bin/bash
```

#### 파드 관리 고급 옵션

```bash
# 모든 네임스페이스의 파드 조회
kubectl get pods --all-namespaces

# 레이블 선택기로 조회
kubectl get pods -l app=nginx

# 파드 상태별 정렬
kubectl get pods --sort-by=.status.phase

# JSON 형태로 출력
kubectl get pod nginx -o json

# YAML 형태로 출력
kubectl get pod nginx -o yaml
```

### 디플로이먼트(Deployment) 관리

#### 디플로이먼트 생성

```bash
# 디플로이먼트 생성
kubectl create deployment nginx-deployment --image=nginx

# 레플리카 수 지정
kubectl create deployment nginx-deployment --image=nginx --replicas=3

# 포트 노출
kubectl create deployment nginx-deployment --image=nginx --port=80
```

#### 디플로이먼트 관리

```bash
# 디플로이먼트 조회
kubectl get deployments

# 디플로이먼트 상세 정보
kubectl describe deployment nginx-deployment

# 디플로이먼트 스케일링
kubectl scale deployment nginx-deployment --replicas=5

# 롤링 업데이트
kubectl set image deployment/nginx-deployment nginx=nginx:1.21

# 롤아웃 상태 확인
kubectl rollout status deployment/nginx-deployment

# 롤아웃 히스토리
kubectl rollout history deployment/nginx-deployment

# 이전 버전으로 롤백
kubectl rollout undo deployment/nginx-deployment
```

### 서비스(Service) 관리

#### 서비스 생성

```bash
# ClusterIP 서비스 (기본값)
kubectl expose deployment nginx-deployment --port=80 --target-port=80

# NodePort 서비스
kubectl expose deployment nginx-deployment --type=NodePort --port=80

# LoadBalancer 서비스
kubectl expose deployment nginx-deployment --type=LoadBalancer --port=80

# 서비스 조회
kubectl get services

# 서비스 상세 정보
kubectl describe service nginx-deployment
```

## 네임스페이스 관리

### 네임스페이스 기본 조작

```bash
# 네임스페이스 생성
kubectl create namespace production

# 네임스페이스 조회
kubectl get namespaces

# 특정 네임스페이스의 리소스 조회
kubectl get pods -n production

# 기본 네임스페이스 설정
kubectl config set-context --current --namespace=production
```

### 네임스페이스별 리소스 관리

```bash
# 네임스페이스에 리소스 생성
kubectl run nginx --image=nginx -n production

# 네임스페이스간 서비스 통신 확인
kubectl get endpoints -n production

# 네임스페이스 삭제 (주의: 모든 리소스 삭제됨)
kubectl delete namespace production
```

## 고급 명령어

### 리소스 모니터링

#### 실시간 모니터링

```bash
# 파드 상태 실시간 감시
kubectl get pods --watch

# 리소스 사용량 확인 (metrics-server 필요)
kubectl top nodes
kubectl top pods

# 이벤트 확인
kubectl get events --sort-by=.metadata.creationTimestamp

# 특정 파드의 이벤트
kubectl get events --field-selector involvedObject.name=nginx
```

#### 디버깅 명령어

```bash
# 파드 내부 네트워크 확인
kubectl exec nginx -- nslookup kubernetes.default

# 파드간 네트워크 연결 테스트
kubectl run tmp-shell --rm -i --tty --image nicolaka/netshoot

# 파드 리소스 사용량 실시간 확인
kubectl exec nginx -- top

# 파드 프로세스 확인
kubectl exec nginx -- ps aux
```

### 파일 기반 리소스 관리

#### YAML 매니페스트 활용

```bash
# YAML 파일로 리소스 생성
kubectl apply -f deployment.yaml

# 디렉토리의 모든 YAML 파일 적용
kubectl apply -f ./configs/

# 원격 YAML 파일 적용
kubectl apply -f https://raw.githubusercontent.com/kubernetes/examples/master/nginx.yaml

# 리소스 상태 확인
kubectl get -f deployment.yaml

# 리소스 삭제
kubectl delete -f deployment.yaml
```

#### Kustomize 활용

```bash
# Kustomization 적용
kubectl apply -k ./overlays/production

# Kustomization 미리보기
kubectl kustomize ./overlays/production

# 빌드된 YAML 확인
kubectl kustomize ./overlays/production > output.yaml
```

## 설정 관리

### ConfigMap과 Secret

#### ConfigMap 관리

```bash
# 리터럴 값으로 ConfigMap 생성
kubectl create configmap app-config --from-literal=database_url=postgres://localhost

# 파일에서 ConfigMap 생성
kubectl create configmap app-config --from-file=config.properties

# ConfigMap 조회
kubectl get configmaps

# ConfigMap 내용 확인
kubectl describe configmap app-config

# ConfigMap 수정
kubectl edit configmap app-config
```

#### Secret 관리

```bash
# Generic Secret 생성
kubectl create secret generic app-secret --from-literal=password=mysecretpassword

# TLS Secret 생성
kubectl create secret tls tls-secret --cert=tls.crt --key=tls.key

# Docker registry Secret 생성
kubectl create secret docker-registry regcred \
  --docker-server=myregistry.io \
  --docker-username=myuser \
  --docker-password=mypassword

# Secret 조회 (값은 base64 인코딩됨)
kubectl get secret app-secret -o yaml

# Secret 값 디코딩
kubectl get secret app-secret -o jsonpath='{.data.password}' | base64 --decode
```

## 스토리지 관리

### 볼륨 관리

```bash
# PersistentVolume 조회
kubectl get pv

# PersistentVolumeClaim 조회
kubectl get pvc

# StorageClass 조회
kubectl get storageclass

# 볼륨 상태 확인
kubectl describe pv my-pv
kubectl describe pvc my-pvc
```

### 동적 볼륨 프로비저닝

```yaml
# StorageClass 예시
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
  zones: us-central1-a, us-central1-b
```

## 네트워킹 관리

### Ingress 관리

```bash
# Ingress 조회
kubectl get ingress

# Ingress 상세 정보
kubectl describe ingress my-ingress

# Ingress Controller 확인
kubectl get pods -n ingress-nginx
```

### NetworkPolicy

```bash
# NetworkPolicy 조회
kubectl get networkpolicies

# NetworkPolicy 적용
kubectl apply -f network-policy.yaml

# 네트워크 연결 테스트
kubectl exec -it pod1 -- nc -zv pod2-service 80
```

## 클러스터 관리

### 노드 관리

```bash
# 노드 조회
kubectl get nodes

# 노드 상세 정보
kubectl describe node worker-node-1

# 노드 라벨 추가
kubectl label node worker-node-1 environment=production

# 노드 라벨 제거
kubectl label node worker-node-1 environment-

# 노드 스케줄링 비활성화
kubectl cordon worker-node-1

# 노드 스케줄링 활성화
kubectl uncordon worker-node-1

# 노드 drain (파드 안전하게 이동)
kubectl drain worker-node-1 --ignore-daemonsets
```

### RBAC 관리

```bash
# 서비스 계정 생성
kubectl create serviceaccount my-service-account

# 역할 생성
kubectl create role pod-reader --verb=get,list,watch --resource=pods

# 역할 바인딩 생성
kubectl create rolebinding read-pods --role=pod-reader --serviceaccount=default:my-service-account

# RBAC 확인
kubectl auth can-i get pods --as=system:serviceaccount:default:my-service-account
```

## 트러블슈팅

### 일반적인 디버깅 명령어

```bash
# 클러스터 상태 종합 확인
kubectl get all --all-namespaces

# 실패한 파드 확인
kubectl get pods --field-selector=status.phase=Failed

# 리소스 사용량이 높은 파드 확인
kubectl top pods --sort-by=cpu

# DNS 문제 디버깅
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default

# 네트워크 연결 테스트
kubectl run -it --rm netshoot --image=nicolaka/netshoot --restart=Never
```

### 로그 분석

```bash
# 여러 파드의 로그 동시 확인
kubectl logs -l app=nginx --tail=100

# 이전 컨테이너의 로그 확인
kubectl logs nginx --previous

# 로그 실시간 스트리밍
kubectl logs -f deployment/nginx-deployment

# 특정 시간 이후 로그
kubectl logs nginx --since=1h
```

## 성능 최적화

### 리소스 관리

```bash
# 리소스 할당량 확인
kubectl describe quota

# 리소스 제한 확인
kubectl describe limitrange

# HorizontalPodAutoscaler 상태
kubectl get hpa

# VerticalPodAutoscaler 상태 (설치된 경우)
kubectl get vpa
```

### 클러스터 최적화

```bash
# 사용하지 않는 리소스 확인
kubectl get pods --all-namespaces --field-selector=status.phase=Succeeded

# 리소스 정리
kubectl delete pods --field-selector=status.phase=Succeeded --all-namespaces

# 이미지 정리 (노드에서 직접 실행)
docker system prune -f
```

## 보안 관리

### 보안 정책

```bash
# PodSecurityPolicy 조회 (deprecated, 대신 PodSecurity admission controller 사용)
kubectl get podsecuritypolicy

# 보안 컨텍스트 확인
kubectl describe pod nginx | grep -A 10 "Security Context"

# 권한 확인
kubectl auth can-i create pods
kubectl auth can-i create pods --as=system:serviceaccount:default:my-sa
```

### 시크릿 스캔

```bash
# 클러스터 내 시크릿 현황
kubectl get secrets --all-namespaces

# 시크릿 타입별 분류
kubectl get secrets --all-namespaces -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,TYPE:.type
```

## 실전 시나리오

### 애플리케이션 배포 전체 과정

```bash
# 1. 네임스페이스 생성
kubectl create namespace myapp

# 2. 시크릿 생성
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=secret123 \
  -n myapp

# 3. ConfigMap 생성
kubectl create configmap app-config \
  --from-literal=database_url=postgres://db:5432/myapp \
  -n myapp

# 4. 디플로이먼트 생성
kubectl create deployment myapp \
  --image=myapp:latest \
  --replicas=3 \
  -n myapp

# 5. 서비스 노출
kubectl expose deployment myapp \
  --port=80 \
  --target-port=8080 \
  --type=ClusterIP \
  -n myapp

# 6. Ingress 설정 (별도 YAML 필요)
kubectl apply -f myapp-ingress.yaml
```

### 롤링 업데이트와 롤백

```bash
# 새 버전 배포
kubectl set image deployment/myapp myapp=myapp:v2.0 -n myapp

# 배포 진행 상황 모니터링
kubectl rollout status deployment/myapp -n myapp

# 문제 발생시 즉시 롤백
kubectl rollout undo deployment/myapp -n myapp

# 특정 리비전으로 롤백
kubectl rollout undo deployment/myapp --to-revision=1 -n myapp
```

## kubectl 플러그인과 도구

### 유용한 kubectl 플러그인

```bash
# krew (kubectl 플러그인 매니저) 설치
kubectl krew install krew

# 인기 플러그인들
kubectl krew install ns          # 네임스페이스 빠른 전환
kubectl krew install ctx         # 컨텍스트 빠른 전환
kubectl krew install tree        # 리소스 트리 구조 확인
kubectl krew install view-secret # 시크릿 값 쉽게 확인
```

### 별칭(Alias) 설정

```bash
# ~/.bashrc 또는 ~/.zshrc에 추가
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias ka='kubectl apply'
alias kdel='kubectl delete'
```

## 마무리

이 가이드에서는 쿠버네티스의 핵심 kubectl 명령어들을 체계적으로 정리했습니다. 쿠버네티스를 효과적으로 사용하려면:

1. **기본 명령어 숙달**: get, describe, apply, delete 등 핵심 명령어 완전 이해
2. **리소스 생명주기 관리**: Pod, Deployment, Service의 생성-수정-삭제 과정 숙지
3. **디버깅 스킬**: logs, exec, events 등을 활용한 문제 해결 능력
4. **보안 인식**: RBAC, Secret, NetworkPolicy 등 보안 관련 리소스 이해
5. **모니터링 습관**: top, describe, get events 등을 통한 상시 모니터링

쿠버네티스는 복잡하지만 강력한 플랫폼입니다. 이 명령어들을 단계적으로 익혀가며 실제 프로젝트에 적용해보시기 바랍니다. 경험이 쌓일수록 더욱 효율적이고 안정적인 컨테이너 오케스트레이션이 가능할 것입니다. 