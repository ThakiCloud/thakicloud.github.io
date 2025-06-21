---
title: "Kubernetes Nginx Ingress로 경로별 더미 서비스 연결 실습 가이드"
date: 2025-06-13
categories:
  - tutorials
  - kubernetes
tags:
  - ingress
  - nginx
  - kubernetes
  - guide
author_profile: true
toc: true
toc_label: "K8s Nginx Ingress 튜토리얼"
---

## 개요

이 문서에서는 Kubernetes 클러스터에 Nginx Ingress Controller를 설치하고, 여러 URL 경로마다 서로 다른 더미 애플리케이션(Pod/Service)로 트래픽을 라우팅하는 방법을 안내합니다.

## 네임스페이스 생성

먼저 네임스페이스를 생성합니다.

```bash
kubectl create namespace nginx-ingress
```

## Nginx Ingress Controller 설치

Helm으로 nginx-ingress 네임스페이스에 설치합니다.

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx -n nginx-ingress --create-namespace
```

설치가 완료되면, 다음 명령어로 Ingress Controller의 EXTERNAL-IP를 확인하세요.

```bash
kubectl get svc -n nginx-ingress -l app.kubernetes.io/name=ingress-nginx
```

## 더미 애플리케이션(Pod/Service) 생성

예시로 `/foo`와 `/bar` 경로에 각각 연결될 더미 서비스를 만듭니다.

### foo 서비스

아래 명령어로 foo 서비스와 디플로이먼트 YAML 파일을 생성할 수 있습니다.

> **중요:** `hashicorp/http-echo` 이미지는 기본적으로 5678 포트에서 리스닝하므로, 반드시 `-listen=:8080` 옵션을 추가해야 서비스가 8080 포트에서 정상 동작합니다.

```bash
cat > foo.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: foo-service
  namespace: nginx-ingress
spec:
  selector:
    app: foo
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: foo-deployment
  namespace: nginx-ingress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: foo
  template:
    metadata:
      labels:
        app: foo
    spec:
      containers:
        - name: foo
          image: hashicorp/http-echo
          args:
            - "-text=foo response"
            - "-listen=:8080"
          ports:
            - containerPort: 8080
EOF
```

적용:

```bash
kubectl apply -f foo.yaml -n nginx-ingress
```

### bar 서비스

아래 명령어로 bar 서비스와 디플로이먼트 YAML 파일을 생성할 수 있습니다.

```bash
cat > bar.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: bar-service
  namespace: nginx-ingress
spec:
  selector:
    app: bar
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bar-deployment
  namespace: nginx-ingress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: bar
  template:
    metadata:
      labels:
        app: bar
    spec:
      containers:
        - name: bar
          image: hashicorp/http-echo
          args:
            - "-text=bar response"
            - "-listen=:8080"
          ports:
            - containerPort: 8080
EOF
```

적용:

```bash
kubectl apply -f bar.yaml -n nginx-ingress
```

## Ingress 리소스 생성

아래 명령어로 Ingress 리소스 YAML 파일을 생성할 수 있습니다.

```bash
cat > ingress.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  namespace: nginx-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: / # 필요시 사용
spec:
  ingressClassName: nginx
  rules:
    - http:
        paths:
          - path: /foo
            pathType: Prefix
            backend:
              service:
                name: foo-service
                port:
                  number: 80
          - path: /bar
            pathType: Prefix
            backend:
              service:
                name: bar-service
                port:
                  number: 80
EOF
```

적용:

```bash
kubectl apply -f ingress.yaml -n nginx-ingress
```

## 테스트

Ingress Controller의 EXTERNAL-IP를 확인한 뒤, 아래와 같이 curl로 테스트합니다.

```bash
kubectl get svc -n nginx-ingress -l app.kubernetes.io/name=ingress-nginx

curl http://<EXTERNAL-IP>/foo
# 결과: foo response

curl http://<EXTERNAL-IP>/bar
# 결과: bar response
```

## 참고

- 공식 문서: [https://kubernetes.github.io/ingress-nginx/](https://kubernetes.github.io/ingress-nginx/)
- 더미 echo 컨테이너: [https://hub.docker.com/r/hashicorp/http-echo](https://hub.docker.com/r/hashicorp/http-echo)
