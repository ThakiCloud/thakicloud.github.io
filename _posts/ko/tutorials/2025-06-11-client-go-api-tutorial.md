---
title: "client-go 완벽 가이드: Kubernetes API 서버 통신 마스터하기"
date: 2025-06-11
categories: 
  - tutorials
  - kubernetes
tags: 
  - client-go
  - kubernetes
  - go
  - API
  - 클러스터
author_profile: true
toc: true
toc_label: 목차
---

Kubernetes 클러스터와 프로그래밍 방식으로 상호작용하기 위한 공식 Go 클라이언트 라이브러리인 client-go에 대해 알아보겠습니다. 이 강력한 라이브러리를 통해 Pod, Service, Deployment 등 Kubernetes 리소스를 관리하는 방법을 단계별로 학습해보겠습니다.

## 🚀 client-go란?

**client-go**는 Kubernetes에서 공식적으로 제공하는 Go 언어용 클라이언트 라이브러리입니다. Kubernetes API 서버와 통신하여 클러스터 리소스를 생성, 조회, 수정, 삭제할 수 있는 완전한 기능을 제공합니다.

### 주요 특징

- **공식 지원**: Kubernetes 프로젝트의 일부로 지속적으로 업데이트됩니다.
- **타입 안전성**: Go의 강력한 타입 시스템을 활용한 안전한 API 호출이 가능합니다.
- **완전한 기능**: kubectl이 제공하는 모든 기능을 프로그래밍 방식으로 사용할 수 있습니다.
- **확장성**: 커스텀 리소스 및 CRD(Custom Resource Definition) 지원이 포함되어 있습니다.

## 📋 사전 준비사항

### 시스템 요구사항

- **Go**: 1.19 이상
- **Kubernetes 클러스터**: minikube, kind, 또는 실제 클러스터
- **kubectl**: 클러스터 접근을 위한 kubeconfig 설정

### 개발 환경 설정

```bash
# Go 모듈 초기화
go mod init client-go-tutorial

# client-go 라이브러리 설치
go get k8s.io/client-go@latest
go get k8s.io/apimachinery@latest
```

## 🔧 기본 설정 및 연결

### kubeconfig 파일 경로 확인

기본적으로 kubeconfig 파일은 `~/.kube/config` 경로에 위치하지만, 사용하는 Kubernetes 환경에 따라 경로가 다를 수 있습니다:

- **표준 설치**: `~/.kube/config`
- **OrbStack 사용 시**: `~/.orbstack/k8s/config.yml`
- **Docker Desktop**: `~/.kube/config`
- **minikube**: `~/.kube/config`

OrbStack을 사용하는 경우, kubeconfig 파일이 `~/.orbstack/k8s/config.yml` 경로에 생성되므로 이를 고려하여 클라이언트를 설정해야 합니다.

### kubeconfig 기반 클라이언트 생성

```go
package main

import (
    "context"
    "fmt"
    "os"
    "path/filepath"

    "k8s.io/client-go/kubernetes"
    "k8s.io/client-go/tools/clientcmd"
    "k8s.io/client-go/util/homedir"
)

func main() {
    // kubeconfig 파일 경로 설정
    var kubeconfig string
    if home := homedir.HomeDir(); home != "" {
        // OrbStack 사용 시 경로 확인
        orbstackConfig := filepath.Join(home, ".orbstack", "k8s", "config.yml")
        if _, err := os.Stat(orbstackConfig); err == nil {
            kubeconfig = orbstackConfig
        } else {
            kubeconfig = filepath.Join(home, ".kube", "config")
        }
    }

    // kubeconfig 로드
    config, err := clientcmd.BuildConfigFromFlags("", kubeconfig)
    if err != nil {
        panic(err.Error())
    }

    // Kubernetes 클라이언트 생성
    clientset, err := kubernetes.NewForConfig(config)
    if err != nil {
        panic(err.Error())
    }

    // 클러스터 정보 확인
    serverVersion, err := clientset.Discovery().ServerVersion()
    if err != nil {
        panic(err.Error())
    }

    fmt.Printf("Connected to Kubernetes cluster version: %s\n", serverVersion.GitVersion)
}
```

### In-Cluster 설정 (Pod 내부에서 실행 시)

```go
package main

import (
    "context"
    "fmt"

    "k8s.io/client-go/kubernetes"
    "k8s.io/client-go/rest"
)

func createInClusterClient() (*kubernetes.Clientset, error) {
    // Pod 내부에서 실행될 때 사용
    config, err := rest.InClusterConfig()
    if err != nil {
        return nil, err
    }

    clientset, err := kubernetes.NewForConfig(config)
    if err != nil {
        return nil, err
    }

    return clientset, nil
}
```

## 📦 Pod 관리하기

### Pod 생성하기

```go
package main

import (
    "context"
    "fmt"

    corev1 "k8s.io/api/core/v1"
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    "k8s.io/client-go/kubernetes"
)

func createPod(clientset *kubernetes.Clientset, namespace string) error {
    pod := &corev1.Pod{
        ObjectMeta: metav1.ObjectMeta{
            Name:      "example-pod",
            Namespace: namespace,
            Labels: map[string]string{
                "app": "example",
            },
        },
        Spec: corev1.PodSpec{
            Containers: []corev1.Container{
                {
                    Name:  "nginx",
                    Image: "nginx:1.21",
                    Ports: []corev1.ContainerPort{
                        {
                            ContainerPort: 80,
                        },
                    },
                    Resources: corev1.ResourceRequirements{
                        Requests: corev1.ResourceList{
                            corev1.ResourceCPU:    "100m",
                            corev1.ResourceMemory: "128Mi",
                        },
                        Limits: corev1.ResourceList{
                            corev1.ResourceCPU:    "500m",
                            corev1.ResourceMemory: "512Mi",
                        },
                    },
                },
            },
            RestartPolicy: corev1.RestartPolicyAlways,
        },
    }

    result, err := clientset.CoreV1().Pods(namespace).Create(
        context.TODO(), pod, metav1.CreateOptions{})
    if err != nil {
        return err
    }

    fmt.Printf("Pod %s created successfully\n", result.GetObjectMeta().GetName())
    return nil
}
```

### Pod 조회하기

```go
func listPods(clientset *kubernetes.Clientset, namespace string) error {
    pods, err := clientset.CoreV1().Pods(namespace).List(
        context.TODO(), metav1.ListOptions{})
    if err != nil {
        return err
    }

    fmt.Printf("Found %d pods in namespace %s:\n", len(pods.Items), namespace)
    for _, pod := range pods.Items {
        fmt.Printf("- Name: %s, Status: %s\n", 
            pod.Name, pod.Status.Phase)
    }

    return nil
}

func getPod(clientset *kubernetes.Clientset, namespace, name string) error {
    pod, err := clientset.CoreV1().Pods(namespace).Get(
        context.TODO(), name, metav1.GetOptions{})
    if err != nil {
        return err
    }

    fmt.Printf("Pod Details:\n")
    fmt.Printf("Name: %s\n", pod.Name)
    fmt.Printf("Namespace: %s\n", pod.Namespace)
    fmt.Printf("Status: %s\n", pod.Status.Phase)
    fmt.Printf("Node: %s\n", pod.Spec.NodeName)
    fmt.Printf("Created: %s\n", pod.CreationTimestamp)

    return nil
}
```

### Pod 삭제하기

```go
func deletePod(clientset *kubernetes.Clientset, namespace, name string) error {
    deletePolicy := metav1.DeletePropagationForeground
    
    err := clientset.CoreV1().Pods(namespace).Delete(
        context.TODO(), name, metav1.DeleteOptions{
            PropagationPolicy: &deletePolicy,
        })
    if err != nil {
        return err
    }

    fmt.Printf("Pod %s deleted successfully\n", name)
    return nil
}
```

## 🚢 Deployment 관리하기

### Deployment 생성하기

```go
package main

import (
    "context"
    "fmt"

    appsv1 "k8s.io/api/apps/v1"
    corev1 "k8s.io/api/core/v1"
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    "k8s.io/client-go/kubernetes"
    "k8s.io/utils/pointer"
)

func createDeployment(clientset *kubernetes.Clientset, namespace string) error {
    deployment := &appsv1.Deployment{
        ObjectMeta: metav1.ObjectMeta{
            Name:      "nginx-deployment",
            Namespace: namespace,
        },
        Spec: appsv1.DeploymentSpec{
            Replicas: pointer.Int32(3),
            Selector: &metav1.LabelSelector{
                MatchLabels: map[string]string{
                    "app": "nginx",
                },
            },
            Template: corev1.PodTemplateSpec{
                ObjectMeta: metav1.ObjectMeta{
                    Labels: map[string]string{
                        "app": "nginx",
                    },
                },
                Spec: corev1.PodSpec{
                    Containers: []corev1.Container{
                        {
                            Name:  "nginx",
                            Image: "nginx:1.21",
                            Ports: []corev1.ContainerPort{
                                {
                                    ContainerPort: 80,
                                },
                            },
                            Resources: corev1.ResourceRequirements{
                                Requests: corev1.ResourceList{
                                    corev1.ResourceCPU:    "100m",
                                    corev1.ResourceMemory: "128Mi",
                                },
                            },
                        },
                    },
                },
            },
        },
    }

    result, err := clientset.AppsV1().Deployments(namespace).Create(
        context.TODO(), deployment, metav1.CreateOptions{})
    if err != nil {
        return err
    }

    fmt.Printf("Deployment %s created successfully\n", result.GetObjectMeta().GetName())
    return nil
}
```

### Deployment 스케일링

```go
func scaleDeployment(clientset *kubernetes.Clientset, namespace, name string, replicas int32) error {
    // 현재 Deployment 가져오기
    deployment, err := clientset.AppsV1().Deployments(namespace).Get(
        context.TODO(), name, metav1.GetOptions{})
    if err != nil {
        return err
    }

    // 레플리카 수 변경
    deployment.Spec.Replicas = &replicas

    // 업데이트 적용
    _, err = clientset.AppsV1().Deployments(namespace).Update(
        context.TODO(), deployment, metav1.UpdateOptions{})
    if err != nil {
        return err
    }

    fmt.Printf("Deployment %s scaled to %d replicas\n", name, replicas)
    return nil
}
```

## 🌐 Service 관리하기

### Service 생성하기

```go
func createService(clientset *kubernetes.Clientset, namespace string) error {
    service := &corev1.Service{
        ObjectMeta: metav1.ObjectMeta{
            Name:      "nginx-service",
            Namespace: namespace,
        },
        Spec: corev1.ServiceSpec{
            Selector: map[string]string{
                "app": "nginx",
            },
            Ports: []corev1.ServicePort{
                {
                    Port:       80,
                    TargetPort: intstr.FromInt(80),
                    Protocol:   corev1.ProtocolTCP,
                },
            },
            Type: corev1.ServiceTypeClusterIP,
        },
    }

    result, err := clientset.CoreV1().Services(namespace).Create(
        context.TODO(), service, metav1.CreateOptions{})
    if err != nil {
        return err
    }

    fmt.Printf("Service %s created successfully\n", result.GetObjectMeta().GetName())
    return nil
}
```

## 👀 리소스 모니터링 및 Watch

### Watch API 사용하기

```go
package main

import (
    "context"
    "fmt"
    "time"

    corev1 "k8s.io/api/core/v1"
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    "k8s.io/apimachinery/pkg/watch"
    "k8s.io/client-go/kubernetes"
)

func watchPods(clientset *kubernetes.Clientset, namespace string) error {
    // Watch 시작
    watchlist, err := clientset.CoreV1().Pods(namespace).Watch(
        context.TODO(), metav1.ListOptions{})
    if err != nil {
        return err
    }
    defer watchlist.Stop()

    fmt.Printf("Watching pods in namespace %s...\n", namespace)

    // 이벤트 수신 및 처리
    for event := range watchlist.ResultChan() {
        pod, ok := event.Object.(*corev1.Pod)
        if !ok {
            continue
        }

        switch event.Type {
        case watch.Added:
            fmt.Printf("Pod Added: %s\n", pod.Name)
        case watch.Modified:
            fmt.Printf("Pod Modified: %s (Status: %s)\n", pod.Name, pod.Status.Phase)
        case watch.Deleted:
            fmt.Printf("Pod Deleted: %s\n", pod.Name)
        }
    }

    return nil
}
```

### Informer 패턴 사용하기

```go
package main

import (
    "context"
    "fmt"
    "time"

    corev1 "k8s.io/api/core/v1"
    "k8s.io/apimachinery/pkg/fields"
    "k8s.io/client-go/kubernetes"
    "k8s.io/client-go/tools/cache"
)

func setupPodInformer(clientset *kubernetes.Clientset, namespace string) {
    // List & Watch 함수 정의
    listWatcher := cache.NewListWatchFromClient(
        clientset.CoreV1().RESTClient(),
        "pods",
        namespace,
        fields.Everything(),
    )

    // Informer 생성
    _, controller := cache.NewInformer(
        listWatcher,
        &corev1.Pod{},
        time.Second*10,
        cache.ResourceEventHandlerFuncs{
            AddFunc: func(obj interface{}) {
                pod := obj.(*corev1.Pod)
                fmt.Printf("Pod Added: %s/%s\n", pod.Namespace, pod.Name)
            },
            UpdateFunc: func(oldObj, newObj interface{}) {
                pod := newObj.(*corev1.Pod)
                fmt.Printf("Pod Updated: %s/%s (Status: %s)\n", 
                    pod.Namespace, pod.Name, pod.Status.Phase)
            },
            DeleteFunc: func(obj interface{}) {
                pod := obj.(*corev1.Pod)
                fmt.Printf("Pod Deleted: %s/%s\n", pod.Namespace, pod.Name)
            },
        },
    )

    // Informer 시작
    stopCh := make(chan struct{})
    defer close(stopCh)
    
    go controller.Run(stopCh)
    
    // 캐시 동기화 대기
    if !cache.WaitForCacheSync(stopCh, controller.HasSynced) {
        fmt.Println("Timed out waiting for caches to sync")
        return
    }

    fmt.Println("Pod informer started successfully")
    
    // 무한 대기 (실제 애플리케이션에서는 적절한 종료 조건 필요)
    <-stopCh
}
```

## 🔍 고급 기능 활용하기

### 라벨 셀렉터를 이용한 필터링

```go
func listPodsWithSelector(clientset *kubernetes.Clientset, namespace, selector string) error {
    pods, err := clientset.CoreV1().Pods(namespace).List(
        context.TODO(), metav1.ListOptions{
            LabelSelector: selector,
        })
    if err != nil {
        return err
    }

    fmt.Printf("Found %d pods matching selector '%s':\n", len(pods.Items), selector)
    for _, pod := range pods.Items {
        fmt.Printf("- %s (Status: %s)\n", pod.Name, pod.Status.Phase)
    }

    return nil
}

// 사용 예시
// listPodsWithSelector(clientset, "default", "app=nginx")
// listPodsWithSelector(clientset, "default", "environment in (production,staging)")
```

### 커스텀 리소스 접근하기

```go
package main

import (
    "context"
    "fmt"

    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    "k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
    "k8s.io/apimachinery/pkg/runtime/schema"
    "k8s.io/client-go/dynamic"
)

func accessCustomResource(dynamicClient dynamic.Interface) error {
    // 커스텀 리소스의 GVR (Group, Version, Resource) 정의
    gvr := schema.GroupVersionResource{
        Group:    "example.com",
        Version:  "v1",
        Resource: "myresources",
    }

    // 커스텀 리소스 목록 조회
    list, err := dynamicClient.Resource(gvr).Namespace("default").List(
        context.TODO(), metav1.ListOptions{})
    if err != nil {
        return err
    }

    fmt.Printf("Found %d custom resources\n", len(list.Items))
    for _, item := range list.Items {
        fmt.Printf("- Name: %s\n", item.GetName())
    }

    return nil
}
```

## 🛡️ 에러 처리 및 모범 사례

### 안전한 에러 처리

```go
package main

import (
    "context"
    "fmt"

    "k8s.io/apimachinery/pkg/api/errors"
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    "k8s.io/client-go/kubernetes"
)

func safeGetPod(clientset *kubernetes.Clientset, namespace, name string) error {
    pod, err := clientset.CoreV1().Pods(namespace).Get(
        context.TODO(), name, metav1.GetOptions{})
    
    if err != nil {
        if errors.IsNotFound(err) {
            fmt.Printf("Pod %s not found in namespace %s\n", name, namespace)
            return nil
        } else if errors.IsForbidden(err) {
            fmt.Printf("Access denied to pod %s\n", name)
            return err
        } else {
            fmt.Printf("Unexpected error: %v\n", err)
            return err
        }
    }

    fmt.Printf("Pod found: %s (Status: %s)\n", pod.Name, pod.Status.Phase)
    return nil
}

func createResourceSafely(clientset *kubernetes.Clientset) error {
    // 리소스 생성 시도
    _, err := createPod(clientset, "default")
    
    if err != nil {
        if errors.IsAlreadyExists(err) {
            fmt.Println("Pod already exists, skipping creation")
            return nil
        }
        return fmt.Errorf("failed to create pod: %w", err)
    }

    return nil
}
```

### 컨텍스트와 타임아웃 관리

```go
package main

import (
    "context"
    "time"

    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    "k8s.io/client-go/kubernetes"
)

func listPodsWithTimeout(clientset *kubernetes.Clientset, namespace string) error {
    // 10초 타임아웃 설정
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()

    pods, err := clientset.CoreV1().Pods(namespace).List(ctx, metav1.ListOptions{})
    if err != nil {
        return err
    }

    fmt.Printf("Found %d pods\n", len(pods.Items))
    return nil
}
```

## 📝 실전 예제: 전체 애플리케이션

다음은 Pod와 Service를 함께 관리하는 완전한 예제입니다.

```go
package main

import (
    "context"
    "fmt"
    "log"
    "path/filepath"
    "time"

    appsv1 "k8s.io/api/apps/v1"
    corev1 "k8s.io/api/core/v1"
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    "k8s.io/apimachinery/pkg/util/intstr"
    "k8s.io/client-go/kubernetes"
    "k8s.io/client-go/tools/clientcmd"
    "k8s.io/client-go/util/homedir"
    "k8s.io/utils/pointer"
)

type AppManager struct {
    clientset *kubernetes.Clientset
    namespace string
}

func NewAppManager(namespace string) (*AppManager, error) {
    var kubeconfig string
    if home := homedir.HomeDir(); home != "" {
        kubeconfig = filepath.Join(home, ".kube", "config")
    }

    config, err := clientcmd.BuildConfigFromFlags("", kubeconfig)
    if err != nil {
        return nil, err
    }

    clientset, err := kubernetes.NewForConfig(config)
    if err != nil {
        return nil, err
    }

    return &AppManager{
        clientset: clientset,
        namespace: namespace,
    }, nil
}

func (am *AppManager) DeployApp(appName, image string, replicas int32) error {
    // Deployment 생성
    deployment := &appsv1.Deployment{
        ObjectMeta: metav1.ObjectMeta{
            Name:      appName,
            Namespace: am.namespace,
        },
        Spec: appsv1.DeploymentSpec{
            Replicas: pointer.Int32(replicas),
            Selector: &metav1.LabelSelector{
                MatchLabels: map[string]string{
                    "app": appName,
                },
            },
            Template: corev1.PodTemplateSpec{
                ObjectMeta: metav1.ObjectMeta{
                    Labels: map[string]string{
                        "app": appName,
                    },
                },
                Spec: corev1.PodSpec{
                    Containers: []corev1.Container{
                        {
                            Name:  appName,
                            Image: image,
                            Ports: []corev1.ContainerPort{
                                {
                                    ContainerPort: 80,
                                },
                            },
                        },
                    },
                },
            },
        },
    }

    _, err := am.clientset.AppsV1().Deployments(am.namespace).Create(
        context.TODO(), deployment, metav1.CreateOptions{})
    if err != nil {
        return fmt.Errorf("failed to create deployment: %w", err)
    }

    // Service 생성
    service := &corev1.Service{
        ObjectMeta: metav1.ObjectMeta{
            Name:      appName + "-service",
            Namespace: am.namespace,
        },
        Spec: corev1.ServiceSpec{
            Selector: map[string]string{
                "app": appName,
            },
            Ports: []corev1.ServicePort{
                {
                    Port:       80,
                    TargetPort: intstr.FromInt(80),
                },
            },
            Type: corev1.ServiceTypeClusterIP,
        },
    }

    _, err = am.clientset.CoreV1().Services(am.namespace).Create(
        context.TODO(), service, metav1.CreateOptions{})
    if err != nil {
        return fmt.Errorf("failed to create service: %w", err)
    }

    fmt.Printf("App %s deployed successfully\n", appName)
    return nil
}

func (am *AppManager) WaitForDeployment(appName string, timeout time.Duration) error {
    ctx, cancel := context.WithTimeout(context.Background(), timeout)
    defer cancel()

    for {
        select {
        case <-ctx.Done():
            return fmt.Errorf("timeout waiting for deployment %s", appName)
        default:
            deployment, err := am.clientset.AppsV1().Deployments(am.namespace).Get(
                context.TODO(), appName, metav1.GetOptions{})
            if err != nil {
                return err
            }

            if deployment.Status.ReadyReplicas == *deployment.Spec.Replicas {
                fmt.Printf("Deployment %s is ready\n", appName)
                return nil
            }

            fmt.Printf("Waiting for deployment %s... (%d/%d replicas ready)\n",
                appName, deployment.Status.ReadyReplicas, *deployment.Spec.Replicas)
            time.Sleep(5 * time.Second)
        }
    }
}

func (am *AppManager) DeleteApp(appName string) error {
    // Deployment 삭제
    err := am.clientset.AppsV1().Deployments(am.namespace).Delete(
        context.TODO(), appName, metav1.DeleteOptions{})
    if err != nil {
        return fmt.Errorf("failed to delete deployment: %w", err)
    }

    // Service 삭제
    err = am.clientset.CoreV1().Services(am.namespace).Delete(
        context.TODO(), appName+"-service", metav1.DeleteOptions{})
    if err != nil {
        return fmt.Errorf("failed to delete service: %w", err)
    }

    fmt.Printf("App %s deleted successfully\n", appName)
    return nil
}

func main() {
    appManager, err := NewAppManager("default")
    if err != nil {
        log.Fatal(err)
    }

    // 애플리케이션 배포
    err = appManager.DeployApp("my-nginx", "nginx:1.21", 3)
    if err != nil {
        log.Fatal(err)
    }

    // 배포 완료 대기
    err = appManager.WaitForDeployment("my-nginx", 5*time.Minute)
    if err != nil {
        log.Fatal(err)
    }

    fmt.Println("App is running! Press Ctrl+C to clean up and exit.")
    
    // 여기서 필요한 작업 수행
    time.Sleep(30 * time.Second)

    // 정리
    err = appManager.DeleteApp("my-nginx")
    if err != nil {
        log.Fatal(err)
    }
}
```

## 🔧 디버깅 및 문제 해결

### 로깅 설정

```go
package main

import (
    "flag"
    "k8s.io/klog/v2"
)

func init() {
    // klog 플래그 초기화
    klog.InitFlags(nil)
    
    // 로그 레벨 설정 (0: INFO, 1: DEBUG, 2: TRACE)
    flag.Set("v", "2")
    flag.Parse()
}

func main() {
    klog.Info("Starting Kubernetes client application")
    // ... 나머지 코드
}
```

### 네트워크 연결 문제 해결

```go
func diagnoseConnection(clientset *kubernetes.Clientset) {
    // 1. 서버 버전 확인
    version, err := clientset.Discovery().ServerVersion()
    if err != nil {
        fmt.Printf("Cannot connect to API server: %v\n", err)
        return
    }
    fmt.Printf("Connected to Kubernetes %s\n", version.GitVersion)

    // 2. 네임스페이스 목록 확인
    namespaces, err := clientset.CoreV1().Namespaces().List(
        context.TODO(), metav1.ListOptions{})
    if err != nil {
        fmt.Printf("Cannot list namespaces: %v\n", err)
        return
    }
    fmt.Printf("Found %d namespaces\n", len(namespaces.Items))

    // 3. 현재 사용자 권한 확인
    selfSubjectRulesReview := &authorizationv1.SelfSubjectRulesReview{
        Spec: authorizationv1.SelfSubjectRulesReviewSpec{
            Namespace: "default",
        },
    }
    
    result, err := clientset.AuthorizationV1().SelfSubjectRulesReviews().Create(
        context.TODO(), selfSubjectRulesReview, metav1.CreateOptions{})
    if err != nil {
        fmt.Printf("Cannot check permissions: %v\n", err)
        return
    }
    
    fmt.Printf("User has %d resource rules and %d non-resource rules\n",
        len(result.Status.ResourceRules), len(result.Status.NonResourceRules))
}
```

## 📚 모범 사례 및 팁

### 1. 리소스 관리

```go
// 항상 적절한 리소스 제한 설정
resources := corev1.ResourceRequirements{
    Requests: corev1.ResourceList{
        corev1.ResourceCPU:    "100m",
        corev1.ResourceMemory: "128Mi",
    },
    Limits: corev1.ResourceList{
        corev1.ResourceCPU:    "500m",
        corev1.ResourceMemory: "512Mi",
    },
}
```

### 2. 라벨과 어노테이션 활용

```go
// 일관된 라벨링 전략 사용
labels := map[string]string{
    "app.kubernetes.io/name":       "myapp",
    "app.kubernetes.io/instance":   "myapp-prod",
    "app.kubernetes.io/version":    "1.0.0",
    "app.kubernetes.io/component":  "frontend",
    "app.kubernetes.io/part-of":    "myapp-system",
    "app.kubernetes.io/managed-by": "client-go",
}
```

### 3. 헬스체크 및 모니터링

```go
// Readiness와 Liveness 프로브 설정
probes := &corev1.Probe{
    ProbeHandler: corev1.ProbeHandler{
        HTTPGet: &corev1.HTTPGetAction{
            Path: "/health",
            Port: intstr.FromInt(8080),
        },
    },
    InitialDelaySeconds: 10,
    PeriodSeconds:       10,
}

container.ReadinessProbe = probes
container.LivenessProbe = probes
```

## 🎯 마무리

client-go는 Kubernetes 클러스터를 프로그래밍 방식으로 관리할 수 있는 강력한 도구입니다. 이 가이드에서 다룬 기본 개념과 예제를 바탕으로 다음 단계로 나아가시기 바랍니다.

### 다음 학습 단계

- **Controller 패턴**: Kubernetes 컨트롤러 개발하기
- **Custom Resource Definitions**: 커스텀 리소스 생성 및 관리
- **Operator 개발**: Kubernetes 오퍼레이터 구축하기
- **성능 최적화**: 대규모 클러스터에서의 효율적인 리소스 관리

### 유용한 리소스

- [client-go 공식 문서](https://pkg.go.dev/k8s.io/client-go)
- [Kubernetes API Reference](https://kubernetes.io/docs/reference/kubernetes-api/)
- [Sample Controller](https://github.com/kubernetes/sample-controller)

client-go를 활용하여 Kubernetes 네이티브 애플리케이션을 개발하고, 클러스터 운영을 자동화해보시기 바랍니다.
