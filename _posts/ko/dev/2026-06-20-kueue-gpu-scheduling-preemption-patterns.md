---
title: "Kueue로 GPU 워크로드 선점 제어하기: ClusterQueue 설계와 우선순위 패턴"
excerpt: "Kueue의 선점(Preemption) 메커니즘과 ClusterQueue 설계 원칙을 실제 AI/ML 플랫폼 운용 관점에서 정리했습니다."
seo_title: "Kueue GPU 스케줄링 선점 패턴 ClusterQueue 설계 - Thaki Cloud"
seo_description: "Kueue ClusterQueue 설계, 워크로드 우선순위, GPU 선점 정책, quota borrowing, MultiKueue 멀티클러스터 배포 패턴을 실전 예제와 함께 설명합니다."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - dev
tags: [kueue, kubernetes, gpu-scheduling, preemption, clusterqueue, ai-platform, kueue-v1beta1, mlops]
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/dev/kueue-gpu-scheduling-preemption-patterns/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 8분

GPU 클러스터를 여러 팀이 공유할 때 생기는 가장 흔한 문제는 두 가지다. 하나는 낮은 팀이 점유한 GPU를 높은 우선순위 작업이 가져올 방법이 없다는 것, 다른 하나는 어떤 팀이 쉬는 동안 GPU가 놀고 있다는 것. Kueue는 이 두 문제를 선점(Preemption)과 쿼터 빌림(Quota Borrowing)으로 다룬다.

## Kueue가 기존 Kubernetes 스케줄러와 다른 점

Kubernetes 기본 스케줄러는 Pod이 이미 Running 상태가 되면 건드리지 않는다. PriorityClass로 Pending Pod 간 순서를 정할 수는 있지만, 실행 중인 낮은 우선순위 Job을 밀어내는 로직이 없다.

Kueue는 Workload라는 추상 레이어를 Pod 위에 올린다. 스케줄러가 아니라 워크로드 큐 관리자 역할을 한다. ClusterQueue가 쿼터를 정의하고, Kueue가 어떤 Workload를 언제 Admit할지, 누군가의 Workload를 Preempt할지를 결정한다.

```
요청 도착 -> LocalQueue -> ClusterQueue -> Admit 또는 Pending
                                          ↓
                                    쿼터 초과 시
                                    선점 대상 탐색
                                    -> 낮은 우선순위 Preempt
```

## ClusterQueue 설계 기본

ClusterQueue는 팀이나 프로젝트 단위로 쿼터를 설정하는 오브젝트다. GPU, CPU, 메모리를 리소스 플레이버별로 할당한다.

```yaml
apiVersion: kueue.x-k8s.io/v1beta1
kind: ClusterQueue
metadata:
  name: inference-team
spec:
  namespaceSelector:
    matchLabels:
      kueue.x-k8s.io/team: inference
  resourceGroups:
  - coveredResources: ["cpu", "memory", "nvidia.com/gpu"]
    flavors:
    - name: h100-flavor
      resources:
      - name: nvidia.com/gpu
        nominalQuota: "8"
        borrowingLimit: "4"    # 다른 팀 쿼터에서 최대 4개까지 빌릴 수 있음
      - name: cpu
        nominalQuota: "64"
      - name: memory
        nominalQuota: "256Gi"
  preemption:
    reclaimWithinCohort: LowerPriority   # 빌려간 쿼터를 회수할 때 낮은 우선순위 선점
    borrowWithinCohort:
      policy: LowerPriority
      maxPriorityThreshold: 100
    withinClusterQueue: LowerPriority    # 같은 큐 내에서 낮은 우선순위 선점
```

Cohort는 쿼터를 공유하는 ClusterQueue 그룹이다. 같은 Cohort에 묶인 큐들은 서로 쿼터를 빌려 쓸 수 있다.

## 우선순위 설계 패턴

GPU 클러스터에서 실용적인 우선순위 계층은 보통 세 단계로 나뉜다.

### 1계층: 프로덕션 인퍼런스 (최고 우선순위)

서빙 엔드포인트는 중단이 곧 장애다. `PreemptLowerPriority` 정책을 달고, 트래픽 급증 시 하위 우선순위 학습 Pod을 즉시 회수할 수 있어야 한다.

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: inference-prod
value: 1000
preemptionPolicy: PreemptLowerPriority
globalDefault: false
```

### 2계층: 대화형 실험 (중간 우선순위)

연구자가 Jupyter 세션이나 단기 실험을 돌리는 워크로드. 훈련보다 반응속도가 중요하지만 서빙보다는 낮다.

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: interactive-experiment
value: 500
preemptionPolicy: PreemptLowerPriority
```

### 3계층: 배치 학습 (낮은 우선순위)

긴 학습 Job은 가장 먼저 선점 대상이 된다. 체크포인트 저장 간격을 짧게 유지하면 선점으로 인한 손실을 최소화할 수 있다.

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: batch-training
value: 100
preemptionPolicy: Never    # 이 레벨이 다른 걸 선점하지는 않음
```

## Quota Borrowing 실제 사용법

Borrowing은 쿼터를 낭비하지 않으면서 버스트 용량을 확보하는 메커니즘이다. inference-team이 8개 GPU를 할당받았지만 4개만 쓰고 있다면, training-team이 그 4개를 빌릴 수 있다.

```yaml
# training-team ClusterQueue
spec:
  resourceGroups:
  - flavors:
    - name: h100-flavor
      resources:
      - name: nvidia.com/gpu
        nominalQuota: "4"
        borrowingLimit: "8"   # 최대 8개까지 빌릴 수 있음 (nominalQuota + 빌림 = 최대 12)
  cohort: shared-gpu-pool    # inference-team과 같은 코호트
```

inference-team이 새 작업을 제출하면 Kueue가 training-team에서 빌려간 GPU를 회수한다. 이때 회수 정책이 `reclaimWithinCohort: LowerPriority`면 낮은 우선순위 작업부터 선점한다.

실제로 PodDisruptionBudget과의 상호작용에서 예상치 못한 동작이 나올 수 있다. 선점 시 Pod 종료 유예 시간(terminationGracePeriodSeconds)도 고려해야 한다. 체크포인트를 저장하는 데 필요한 시간보다 짧으면 체크포인트가 유실된다.

## GPU 노드 보호

CPU 워크로드가 GPU 노드에 스케줄되는 걸 막는 설정이다. GPU 노드에 taint를 달고, GPU 워크로드에만 toleration을 붙인다.

```bash
# GPU 노드에 taint 추가
kubectl taint nodes <gpu-node> nvidia.com/gpu=present:NoSchedule
```

```yaml
# Kueue Workload의 toleration
spec:
  podSets:
  - name: main
    template:
      spec:
        tolerations:
        - key: nvidia.com/gpu
          operator: Equal
          value: present
          effect: NoSchedule
```

이 조합이 없으면 로깅 수집기, 프록시, 모니터링 에이전트 같은 CPU 바운드 데몬셋이 GPU 노드의 자원을 점유한다.

## MultiKueue: 멀티클러스터 작업 분산

2026년 Kueue 로드맵에서 주요 기능으로 올라와 있는 MultiKueue는 현재 베타 상태로 기본 활성화되어 있다. 관리 클러스터(manager)가 작업을 받아 워커 클러스터들로 분산한다.

```
[manager cluster]
  MultiKueue ClusterQueue
       |
  -----+-----
  |         |
[worker-1] [worker-2]
(A100 x 8) (H100 x 4)
```

관리 클러스터에 워커 클러스터를 등록한다.

```yaml
apiVersion: kueue.x-k8s.io/v1beta1
kind: MultiKueueCluster
metadata:
  name: worker-cluster-a100
spec:
  kubeConfig:
    locationType: Secret
    location: worker-a100-kubeconfig
```

MultiKueue Dispatcher를 통해 분산 알고리즘을 커스터마이징할 수 있다. 빌트인 알고리즘 외에 사용자 정의 디스패처를 플러그인 형태로 연결하는 방식이다.

## 협력적 선점(Cooperative Preemption)과 체크포인트

2026년 Kueue 로드맵에서 주목할 기능이 협력적 선점이다. 체크포인트를 구현한 워크로드는 선점 신호를 받았을 때 즉시 종료되지 않고 상태를 저장한 뒤 종료할 수 있다.

현재 단계에서는 `terminationGracePeriodSeconds`를 충분히 길게 잡고, 학습 코드에서 SIGTERM 핸들러로 체크포인트를 저장하는 방식으로 유사한 효과를 낸다.

```python
import signal
import sys

def checkpoint_and_exit(signum, frame):
    save_checkpoint(model, optimizer, current_epoch)
    sys.exit(0)

signal.signal(signal.SIGTERM, checkpoint_and_exit)
```

협력적 선점이 정식 지원되면 체크포인트 완료를 Kueue가 확인한 뒤 새 워크로드를 Admit하는 흐름이 될 것이다.

## 실무에서 자주 마주치는 함정

**함정 1: 선점 정책을 프로덕션 투입 전에 검증하지 않는다.** 개발 클러스터에서 선점 시나리오를 한 번 실제로 돌려봐야 한다. PDB, 유예 시간, 체크포인트 저장 시간의 조합이 예상대로 동작하는지 확인해야 한다.

**함정 2: Cohort 없이 borrowingLimit을 설정한다.** Cohort에 묶이지 않은 ClusterQueue는 borrowingLimit을 설정해도 빌릴 대상이 없다.

**함정 3: LocalQueue와 ClusterQueue를 혼동한다.** LocalQueue는 네임스페이스 스코프, ClusterQueue는 클러스터 스코프다. 네임스페이스별 팀 격리는 LocalQueue와 namespaceSelector 조합으로 구현한다.

## 정리

Kueue는 Kubernetes 위에서 GPU 쿼터를 관리하는 몇 안 되는 프로덕션급 도구다. ClusterQueue-Cohort-Preemption 조합으로 팀 간 공정한 GPU 분배를 코드로 표현할 수 있다. 선점 정책은 반드시 실제 워크로드로 검증하고, 체크포인트 저장 시간을 terminationGracePeriodSeconds 안에 맞춰야 손실 없는 선점이 된다.
