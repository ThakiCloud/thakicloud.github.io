---
title: "GPU Workload Preemption with Kueue: ClusterQueue Design and Priority Patterns"
excerpt: "Kueue's preemption mechanism and ClusterQueue design principles from the perspective of operating a real AI/ML platform."
seo_title: "Kueue GPU Scheduling Preemption Patterns ClusterQueue Design - Thaki Cloud"
seo_description: "Kueue ClusterQueue design, workload priority, GPU preemption policy, quota borrowing, and MultiKueue multi-cluster deployment patterns with practical examples."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - dev
tags: [kueue, kubernetes, gpu-scheduling, preemption, clusterqueue, ai-platform, kueue-v1beta1, mlops]
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/dev/kueue-gpu-scheduling-preemption-patterns/"
reading_time: true
lang: en
---

⏱️ **Estimated reading time**: 8 min

Sharing a GPU cluster across multiple teams surfaces two recurring problems. First, a high-priority job has no way to reclaim GPUs held by a lower-priority team. Second, GPUs sit idle while a team is not actively using them. Kueue addresses both problems through Preemption and Quota Borrowing.

## How Kueue Differs from the Default Kubernetes Scheduler

The default Kubernetes scheduler does not touch a Pod once it reaches the Running state. PriorityClass can order Pending Pods, but there is no built-in mechanism to evict a lower-priority running Job to make room for a higher-priority one.

Kueue inserts a Workload abstraction above Pods. Rather than acting as a scheduler, it acts as a workload queue manager. ClusterQueues define quotas; Kueue decides which Workload to Admit, when to Admit it, and whether to Preempt another Workload.

```
Request arrives -> LocalQueue -> ClusterQueue -> Admit or Pending
                                                 |
                                           when quota exceeded
                                           search for preemption target
                                           -> Preempt lower priority
```

## ClusterQueue Design Basics

A ClusterQueue sets quotas per team or project. GPU, CPU, and memory are allocated per resource flavor.

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
        borrowingLimit: "4"    # can borrow up to 4 from another team's quota
      - name: cpu
        nominalQuota: "64"
      - name: memory
        nominalQuota: "256Gi"
  preemption:
    reclaimWithinCohort: LowerPriority   # preempt lower priority when reclaiming borrowed quota
    borrowWithinCohort:
      policy: LowerPriority
      maxPriorityThreshold: 100
    withinClusterQueue: LowerPriority    # preempt lower priority within the same queue
```

A Cohort is a group of ClusterQueues that share quota. Queues within the same Cohort can borrow from one another.

## Priority Design Patterns

A practical priority hierarchy for a GPU cluster typically has three tiers.

### Tier 1: Production Inference (highest priority)

A serving endpoint that goes down is an outage. Attach `PreemptLowerPriority` and ensure that a traffic spike can immediately reclaim GPUs from lower-priority training Pods.

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: inference-prod
value: 1000
preemptionPolicy: PreemptLowerPriority
globalDefault: false
```

### Tier 2: Interactive Experiments (medium priority)

Workloads where researchers run Jupyter sessions or short experiments. Responsiveness matters more than for training, but less than for serving.

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: interactive-experiment
value: 500
preemptionPolicy: PreemptLowerPriority
```

### Tier 3: Batch Training (low priority)

Long training jobs are the first preemption target. Keeping checkpoint intervals short minimizes the work lost when a preemption occurs.

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: batch-training
value: 100
preemptionPolicy: Never    # this tier does not preempt anything above it
```

## Quota Borrowing in Practice

Borrowing avoids quota waste while still providing burst capacity. If inference-team holds 8 GPU slots but is only using 4, training-team can borrow those 4.

```yaml
# training-team ClusterQueue
spec:
  resourceGroups:
  - flavors:
    - name: h100-flavor
      resources:
      - name: nvidia.com/gpu
        nominalQuota: "4"
        borrowingLimit: "8"   # can borrow up to 8 (nominalQuota + borrowed = 12 max)
  cohort: shared-gpu-pool    # same cohort as inference-team
```

When inference-team submits new work, Kueue reclaims the borrowed GPUs from training-team. With `reclaimWithinCohort: LowerPriority`, lower-priority workloads are preempted first.

In practice, interaction with PodDisruptionBudget can produce unexpected behavior. The Pod termination grace period (`terminationGracePeriodSeconds`) must also be accounted for. If the grace period is shorter than the time needed to write a checkpoint, the checkpoint is lost.

## Protecting GPU Nodes

Prevent CPU workloads from landing on GPU nodes by tainting GPU nodes and attaching tolerations only to GPU workloads.

```bash
# add taint to GPU node
kubectl taint nodes <gpu-node> nvidia.com/gpu=present:NoSchedule
```

```yaml
# toleration in Kueue Workload
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

Without this combination, CPU-bound DaemonSets such as log collectors, proxies, and monitoring agents consume GPU node resources.

## MultiKueue: Distributing Work Across Clusters

MultiKueue is currently in beta and enabled by default. It is a major feature on the 2026 Kueue roadmap. A manager cluster receives jobs and distributes them across worker clusters.

```
[manager cluster]
  MultiKueue ClusterQueue
       |
  -----+-----
  |         |
[worker-1] [worker-2]
(A100 x 8) (H100 x 4)
```

Register worker clusters in the manager cluster:

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

The distribution algorithm can be customized through the MultiKueue Dispatcher. Custom dispatchers are wired in as plugins alongside the built-in algorithms.

## Cooperative Preemption and Checkpoints

Cooperative Preemption is another notable item on the 2026 Kueue roadmap. Workloads that implement checkpointing would, upon receiving a preemption signal, save state and then exit rather than terminating immediately.

Until that feature ships, the practical equivalent is to set `terminationGracePeriodSeconds` long enough and write a SIGTERM handler in the training code that saves a checkpoint before exiting.

```python
import signal
import sys

def checkpoint_and_exit(signum, frame):
    save_checkpoint(model, optimizer, current_epoch)
    sys.exit(0)

signal.signal(signal.SIGTERM, checkpoint_and_exit)
```

When Cooperative Preemption is formally supported, the expected flow will have Kueue wait for the checkpoint to complete before Admitting the new Workload.

## Common Pitfalls

**Pitfall 1: Not validating preemption policy before going to production.** Run a real preemption scenario on a development cluster. Verify that the combination of PDB, grace period, and checkpoint duration behaves as expected.

**Pitfall 2: Setting borrowingLimit without a Cohort.** A ClusterQueue not attached to a Cohort has nothing to borrow from, regardless of borrowingLimit.

**Pitfall 3: Confusing LocalQueue and ClusterQueue.** LocalQueue is namespace-scoped; ClusterQueue is cluster-scoped. Per-namespace team isolation is implemented with LocalQueue and namespaceSelector together.

## Summary

Kueue is one of the very few production-grade tools for managing GPU quotas on Kubernetes. The ClusterQueue-Cohort-Preemption combination lets you express fair GPU allocation across teams as code. Always validate preemption policies against real workloads, and make sure the checkpoint write time fits inside `terminationGracePeriodSeconds` to achieve lossless preemption.
