---
title: "GPU 스케일링의 심층 이해: Google DeepMind JAX 스케일링 가이드 분석"
excerpt: "NVIDIA GPU 아키텍처부터 네트워킹, 대규모 언어 모델 훈련까지 - GPU 기반 ML 시스템의 성능 최적화를 위한 포괄적 이론 분석"
seo_title: "GPU 스케일링 가이드: H100/B200 아키텍처와 LLM 훈련 최적화 - Thaki Cloud"
seo_description: "Google DeepMind의 GPU 스케일링 가이드를 바탕으로 NVIDIA H100, B200의 하드웨어 구조부터 네트워킹, 대규모 언어 모델 병렬 처리까지 심층 분석"
date: 2025-08-26
categories:
  - llmops
tags:
  - GPU스케일링
  - NVIDIA-H100
  - NVIDIA-B200
  - LLM훈련
  - 텐서병렬화
  - 데이터병렬화
  - JAX
  - Google-DeepMind
author_profile: true
toc: true
toc_label: "목차"
canonical_url: "https://thakicloud.github.io/ko/llmops/gpu-scaling-comprehensive-guide-jax-google-deepmind/"
lang: ko
permalink: /ko/llmops/gpu-scaling-comprehensive-guide-jax-google-deepmind/
---

⏱️ **예상 읽기 시간**: 25분

## 서론: GPU 스케일링의 현대적 이해

현대 머신러닝 시스템에서 GPU는 단순한 그래픽 처리 장치를 넘어 대규모 언어 모델 훈련과 추론의 핵심 인프라로 자리잡았습니다. [Google DeepMind의 JAX 스케일링 가이드](https://jax-ml.github.io/scaling-book/gpus/)는 GPU 기반 ML 시스템의 성능 최적화에 대한 깊이 있는 통찰을 제공하며, 특히 NVIDIA H100과 B200 같은 최신 GPU 아키텍처에서의 대규모 언어 모델 훈련 전략을 체계적으로 분석합니다. 이 글에서는 해당 가이드의 핵심 내용을 단락별로 상세히 분석하여, GPU 하드웨어의 근본적 구조부터 네트워킹 방식, 그리고 실제 LLM 훈련에서의 병렬화 전략까지 포괄적으로 살펴보겠습니다.

## GPU 하드웨어 아키텍처의 심층 분석

### 기본 구조: 스트리밍 멀티프로세서와 HBM의 조화

현대 머신러닝용 GPU인 H100이나 B200은 본질적으로 행렬 곱셈에 특화된 수많은 컴퓨팅 코어들이 고속 메모리와 연결된 구조로 이해할 수 있습니다. 이들 컴퓨팅 코어는 **스트리밍 멀티프로세서(Streaming Multiprocessors, SMs)**라고 불리며, **HBM(High Bandwidth Memory)**이라는 고속 메모리와 연결되어 있습니다. H100은 132개의 SM을 가지고 있으며 B200은 148개의 SM을 보유하고 있어, TPU와 비교했을 때 훨씬 많은 수의 독립적인 처리 단위를 가지고 있습니다. 이러한 구조적 특성은 GPU가 TPU보다 더 높은 수준의 유연성을 제공할 수 있게 하는 근본적인 이유입니다.

각 SM은 TPU의 텐서 코어와 유사하게 전용 행렬 곱셈 코어인 **텐서 코어(Tensor Core)**, 벡터 연산 유닛인 **워프 스케줄러(Warp Scheduler)**, 그리고 고속 온칩 캐시인 **SMEM**을 포함하고 있습니다. 특히 주목할 점은 TPU가 최대 2개의 독립적인 텐서 코어만을 가지는 반면, 현대 GPU는 100개 이상의 SM을 보유하고 있다는 것입니다. 각 SM의 성능은 TPU의 텐서 코어에 비해 상대적으로 낮지만, 전체 시스템의 유연성은 훨씬 높습니다. 이는 각 SM이 독립적으로 작동할 수 있어 GPU가 수백 개의 별도 작업을 동시에 처리할 수 있기 때문입니다.

### SM 내부 구조: 서브파티션과 처리 단위들

H100 SM의 내부 구조를 더 자세히 살펴보면, 각 SM은 4개의 동일한 서브파티션으로 나뉘어 있으며, 각 서브파티션은 텐서 코어, 16K개의 32비트 레지스터, 그리고 SIMD/SIMT 벡터 연산 유닛인 워프 스케줄러를 포함하고 있습니다. 워프 스케줄러의 개별 ALU들은 **CUDA 코어**라고 불리며, 각 서브파티션의 핵심 구성 요소는 대부분의 FLOP/s를 담당하는 텐서 코어라고 할 수 있지만, 다른 구성 요소들도 중요한 역할을 수행합니다.

**CUDA 코어**는 각 서브파티션에 포함된 ALU 집합으로, SIMD/SIMT 벡터 연산을 담당합니다. 각 ALU는 일반적으로 사이클당 하나의 산술 연산을 수행할 수 있으며, 예를 들어 f32.add와 같은 연산을 처리합니다. 최신 GPU들은 기술적으로 사이클당 두 번의 FLOP을 수행하는 FMA(Fused-Multiply Add) 명령어를 지원하며, NVIDIA는 이를 이용해 명목상의 성능 스펙을 두 배로 표기하는 경우가 많습니다. 각 서브파티션은 32개의 fp32 코어와 더 적은 수의 int32, fp64 코어를 포함하고 있으며, 이들은 모두 각 사이클에서 동일한 명령어를 실행합니다.

**텐서 코어**는 각 서브파티션마다 하나씩 배치되어 있으며, TPU의 MXU와 같은 전용 행렬 곱셈 유닛입니다. 텐서 코어는 GPU FLOP/s의 압도적인 부분을 차지하고 있으며, 예를 들어 H100의 경우 990 bf16 TC TFLOP/s에 비해 CUDA 코어는 단지 66 TFLOP/s만을 제공합니다. 132개의 SM이 1.76GHz로 작동하는 H100에서 각 텐서 코어는 사이클당 약 1024개의 bf16 FLOP을 수행할 수 있으며, 이는 대략 8×8×8 행렬 곱셈에 해당합니다.

### GPU와 TPU의 아키텍처 비교 분석

CUDA 코어는 TPU의 VPU보다 훨씬 더 유연한 구조를 가지고 있습니다. V100 이후의 GPU CUDA 코어는 SIMT(Single Instruction Multiple Threads) 프로그래밍 모델을 사용하는 반면, TPU는 SIMD(Single Instruction Multiple Data) 모델을 사용합니다. TPU의 VPU와 마찬가지로, 서브파티션 내의 CUDA 코어들은 각 사이클에서 동일한 연산을 실행해야 하지만, TPU와 달리 각 CUDA 코어는 자체적인 명령어 포인터를 가지고 있으며 독립적으로 프로그래밍될 수 있습니다. 같은 워프 내의 두 스레드가 서로 다른 연산을 수행하도록 지시받을 때, 실제로는 두 연산을 모두 수행하되 분기하는 연산을 수행하지 않는 코어들을 마스킹하는 방식으로 처리됩니다.

## 메모리 계층구조와 성능 특성

### HBM과 메모리 대역폭 분석

GPU의 메모리 시스템은 성능에 절대적인 영향을 미치는 요소입니다. H100은 80GB의 HBM3 메모리를 3.35TB/s의 대역폭으로 제공하며, B200은 192GB의 HBM3e 메모리를 8TB/s의 대역폭으로 제공합니다. 이는 TPU v5p의 95GB HBM2e와 2.76TB/s 대역폭과 비교했을 때 상당한 개선을 보여줍니다. 특히 B200의 메모리 용량과 대역폭 증가는 대규모 언어 모델의 파라미터를 더 효율적으로 처리할 수 있게 해줍니다.

메모리 계층구조에서 중요한 것은 각 레벨에서의 대역폭과 지연시간입니다. L2 캐시는 40MB 크기로 전체 GPU에서 공유되며, 각 SM의 SMEM은 256KB 크기입니다. B200에서는 텐서 코어가 너무 커져서 입력 데이터가 SMEM에 맞지 않게 되어 **TMEM(Tensor Memory)**이라는 새로운 메모리 공간이 도입되었습니다. 이러한 메모리 계층구조의 변화는 GPU 세대가 발전하면서 텐서 코어의 크기가 지속적으로 증가하고 있음을 보여줍니다.

### 컴퓨트와 메모리 바운드 분석

GPU의 성능은 종종 컴퓨트 바운드인지 메모리 바운드인지에 따라 결정됩니다. H100의 경우 bf16 연산에서 990 TFLOP/s의 성능을 제공하지만, 메모리 대역폭은 3.35TB/s로 제한되어 있습니다. 이는 **arithmetic intensity**라는 개념으로 분석할 수 있으며, 이는 메모리에서 읽은 바이트당 수행되는 연산의 수를 의미합니다. 

$$\text{Arithmetic Intensity} = \frac{\text{FLOP}}{\text{Bytes Accessed}}$$

H100에서 메모리 바운드와 컴퓨트 바운드의 경계는 대략 다음과 같이 계산됩니다:

$$\text{Peak AI} = \frac{990 \times 10^{12} \text{ FLOP/s}}{3.35 \times 10^{12} \text{ B/s}} \times 2 \text{ bytes/bf16} = 591 \text{ FLOP/byte}$$

이 값보다 낮은 arithmetic intensity를 가진 연산은 메모리 바운드가 되며, 높은 값을 가진 연산은 컴퓨트 바운드가 됩니다.

## 네트워킹 아키텍처와 스케일링 전략

### 노드 레벨 네트워킹: NVLink와 NVSwitch

GPU 간의 통신은 성능에 critical한 영향을 미치며, 이는 노드 내부와 노드 간 두 가지 레벨로 나누어 분석할 수 있습니다. 노드 내부에서는 NVLink와 NVSwitch를 통해 GPU들이 연결됩니다. H100 DGX 노드의 경우, 8개의 GPU가 4개의 NVSwitch를 통해 연결되어 있으며, 각 GPU는 18개의 NVLink 4.0 연결을 가지고 있습니다. 각 NVLink는 50GB/s의 양방향 대역폭을 제공하므로, 이론적으로는 각 GPU가 900GB/s의 총 대역폭을 가질 수 있지만, 실제로는 NVSwitch의 대역폭 제한으로 인해 450GB/s로 제한됩니다.

NVSwitch는 중앙집중식 crossbar 스위치로, 64개의 NVLink 포트를 가지고 있으며 1.6TB/s의 총 대역폭을 제공합니다. 8개의 GPU를 가진 노드에서 각 GPU는 실제로 450GB/s의 egress 대역폭을 가지며, 이는 동일한 노드 내의 다른 GPU와 통신할 때의 대역폭입니다. 이러한 구조는 노드 내에서의 텐서 병렬화나 파이프라인 병렬화를 매우 효율적으로 만들어줍니다.

### 노드 간 네트워킹: InfiniBand와 계층적 구조

노드 간 통신은 InfiniBand 네트워크를 통해 이루어지며, 이는 일반적으로 leaf-spine 토폴로지를 사용합니다. H100 SuperPod의 경우, 각 노드는 8개의 400Gbps InfiniBand 연결을 가지고 있어 총 3.2TB/s의 양방향 대역폭을 제공합니다. 하지만 실제로는 각 GPU당 50GB/s의 노드 간 대역폭으로 제한됩니다. 이는 노드 내 대역폭인 450GB/s에 비해 9배 낮은 수치로, 대규모 모델 훈련에서 노드 간 통신을 최소화하는 것이 중요한 이유입니다.

SuperPod 아키텍처는 계층적 구조를 가지고 있으며, **Scalable Unit(SU)** 레벨과 **spine** 레벨로 나뉩니다. SU 레벨에서는 32개의 노드(256개의 GPU)가 8개의 leaf 스위치를 통해 연결되며, 여러 SU가 16개의 spine 스위치를 통해 연결됩니다. 이러한 계층적 구조에서 각 레벨마다 대역폭 제한이 있으며, 특히 spine 레벨에서는 GPU당 25GB/s로 더욱 제한됩니다.

### 네트워크 대역폭과 병렬화 전략의 관계

네트워크 대역폭의 제한은 다양한 병렬화 전략의 효율성에 직접적인 영향을 미칩니다. **데이터 병렬화**의 경우 gradient synchronization을 위해 AllReduce 연산이 필요하며, 이는 네트워크 대역폭에 매우 민감합니다. **텐서 병렬화**는 forward와 backward pass에서 지속적인 GPU 간 통신이 필요하므로 높은 대역폭을 요구합니다. **파이프라인 병렬화**는 상대적으로 적은 통신을 요구하지만, 파이프라인 스테이지 간의 activations 전송이 필요합니다.

$$\text{Communication Cost} = \frac{\text{Data Size}}{\text{Bandwidth}} + \text{Latency}$$

이 수식에서 Data Size는 전송해야 할 데이터의 크기이고, Bandwidth는 사용 가능한 네트워크 대역폭, Latency는 네트워크 지연시간입니다. 대규모 모델 훈련에서는 Data Size가 매우 크기 때문에 Bandwidth 항이 지배적이 되며, 이는 네트워크 토폴로지와 병렬화 전략 선택에 큰 영향을 미칩니다.

## Collective 연산의 성능 분석

### AllReduce와 AllGather 연산의 특성

대규모 분산 훈련에서 가장 중요한 통신 패턴은 collective 연산들입니다. **AllReduce**는 모든 GPU의 gradient를 합산하여 모든 GPU에 동일한 결과를 분배하는 연산으로, 데이터 병렬화에서 핵심적인 역할을 합니다. **AllGather**는 각 GPU의 데이터를 모든 GPU에 수집하는 연산으로, 텐서 병렬화에서 자주 사용됩니다. **ReduceScatter**는 AllReduce의 반대 연산으로, 데이터를 합산한 후 분할하여 분배하는 연산입니다.

노드 내에서 이러한 연산들의 성능은 매우 높습니다. 8개 GPU의 H100 노드에서 AllReduce의 경우, 작은 메시지 크기에서는 지연시간이 지배적이지만, 큰 메시지 크기에서는 대역폭이 지배적이 됩니다. 실제 측정 결과에 따르면, 256MB 이상의 메시지에서는 이론적 대역폭의 80-90% 정도의 성능을 달성할 수 있습니다. 이는 노드 내 텐서 병렬화가 매우 효율적임을 의미합니다.

### 노드 간 Collective 연산의 도전과제

노드 간 collective 연산은 훨씬 더 복잡하고 성능 제약이 큽니다. 계층적 네트워크 구조에서 AllReduce는 일반적으로 **hierarchical AllReduce** 방식으로 구현됩니다. 먼저 각 노드 내에서 AllReduce를 수행하고, 그 결과를 노드 간에 AllReduce한 후, 다시 노드 내에서 broadcast하는 방식입니다. 이 과정의 총 시간은 다음과 같이 모델링할 수 있습니다:

$$T_{AllReduce} = T_{intra} + T_{inter} + T_{broadcast}$$

여기서 $T_{intra}$는 노드 내 AllReduce 시간, $T_{inter}$는 노드 간 AllReduce 시간, $T_{broadcast}$는 노드 내 broadcast 시간입니다. 실제로는 $T_{inter}$가 지배적이 되는 경우가 많으며, 이는 노드 간 대역폭이 노드 내 대역폭보다 훨씬 낮기 때문입니다.

### SHARP와 In-Network Computing

NVIDIA는 네트워크 성능을 개선하기 위해 **SHARP(Scalable Hierarchical Aggregation and Reduction Protocol)**라는 기술을 도입했습니다. SHARP는 InfiniBand 스위치에서 직접 reduction 연산을 수행하여 네트워크 트래픽을 줄이는 기술입니다. 이를 통해 AllReduce 연산의 대역폭을 이론적으로 2배까지 개선할 수 있습니다. 하지만 SHARP는 특정 조건에서만 활성화되며, 모든 상황에서 사용할 수 있는 것은 아닙니다.

$$\text{SHARP Efficiency} = \frac{\text{Actual Bandwidth}}{\text{Theoretical Bandwidth}}$$

실제 측정에서 SHARP가 활성화된 경우 70-80%의 효율성을 보이지만, 비활성화된 경우에는 40-50%의 효율성만을 보입니다. 이러한 성능 차이는 대규모 훈련에서 SHARP 최적화가 매우 중요함을 보여줍니다.

## 대규모 언어 모델을 위한 병렬화 전략

### 데이터 병렬화와 Roofline 분석

데이터 병렬화는 가장 기본적인 분산 훈련 방법으로, 각 GPU가 모델의 전체 복사본을 가지고 서로 다른 배치의 데이터를 처리하는 방식입니다. 이 방법의 주요 제약은 gradient synchronization을 위한 AllReduce 연산입니다. GPU당 batch size가 $B$이고 모델 파라미터 수가 $P$일 때, AllReduce해야 하는 데이터 크기는 $2P$ bytes입니다 (fp16 기준).

데이터 병렬화의 roofline은 다음과 같이 계산됩니다:

$$\text{Compute Time} = \frac{6PBS}{F}$$
$$\text{Communication Time} = \frac{2P}{BW}$$

여기서 $S$는 시퀀스 길이, $F$는 FLOP/s, $BW$는 AllReduce 대역폭입니다. 효율적인 데이터 병렬화를 위해서는 Communication Time이 Compute Time보다 작아야 하므로:

$$B > \frac{PF}{3SBWO}$$

이 수식에서 $O$는 네트워크 오버헤드를 나타내는 상수입니다. H100에서 노드 간 통신의 경우, 이 임계값은 상당히 높아집니다.

### 텐서 병렬화의 효율성 분석

텐서 병렬화는 모델의 가중치 행렬을 여러 GPU에 분할하는 방법으로, 특히 attention 메커니즘과 MLP 레이어에서 효과적입니다. Multi-head attention에서 각 head를 다른 GPU에 배치하거나, MLP의 가중치 행렬을 행 또는 열 방향으로 분할할 수 있습니다. 텐서 병렬화의 주요 장점은 GPU 메모리 사용량을 선형적으로 줄일 수 있다는 것이며, 단점은 forward와 backward pass에서 지속적인 통신이 필요하다는 것입니다.

텐서 병렬화에서 통신 비용은 activation 크기에 비례합니다. 배치 크기가 $B$, 시퀀스 길이가 $S$, 숨겨진 차원이 $H$인 transformer에서 각 attention 레이어는 다음과 같은 통신을 요구합니다:

$$\text{Communication Volume} = 4BSH \text{ bytes}$$

이는 forward pass에서 2번의 AllGather와 backward pass에서 2번의 ReduceScatter로 구성됩니다. 텐서 병렬화가 효율적이려면 이 통신 시간이 computation 시간보다 작아야 합니다.

### 파이프라인 병렬화와 메모리 효율성

파이프라인 병렬화는 모델의 레이어들을 여러 GPU에 순차적으로 배치하는 방법입니다. 이 방법은 메모리 사용량을 효과적으로 줄일 수 있지만, 파이프라인 버블(pipeline bubble)로 인한 GPU 유휴 시간이 발생할 수 있습니다. 파이프라인 병렬화의 효율성은 micro-batch 수와 파이프라인 스테이지 수의 비율에 따라 결정됩니다.

파이프라인 효율성은 다음과 같이 계산할 수 있습니다:

$$\text{Pipeline Efficiency} = \frac{M}{M + P - 1}$$

여기서 $M$은 micro-batch 수, $P$는 파이프라인 스테이지 수입니다. 높은 효율성을 위해서는 $M \gg P$이어야 하지만, micro-batch 크기가 너무 작으면 각 GPU의 활용도가 떨어질 수 있습니다.

### Expert 병렬화와 Mixture of Experts

Mixture of Experts (MoE) 모델에서는 각 토큰이 소수의 전문가(expert)만을 활성화시키므로, expert 병렬화라는 특별한 형태의 병렬화가 필요합니다. 각 expert를 다른 GPU에 배치하고, 입력 토큰들을 적절한 expert가 있는 GPU로 라우팅합니다. 이 과정에서 **AllToAll** collective 연산이 핵심적인 역할을 합니다.

Expert 병렬화에서 통신 비용은 expert 활용의 불균형성에 크게 의존합니다. 모든 expert가 균등하게 사용되는 이상적인 경우 통신 비용은 다음과 같습니다:

$$\text{AllToAll Cost} = \frac{BSH \cdot k}{E} \cdot 2$$

여기서 $k$는 토큰당 활성화되는 expert 수, $E$는 총 expert 수입니다. 하지만 실제로는 expert 간 부하 불균형으로 인해 통신 비용이 증가할 수 있습니다.

## 실제 모델 훈련에서의 최적화 전략

### LLaMA 모델 훈련 사례 분석

실제 대규모 언어 모델 훈련에서는 여러 병렬화 기법을 조합하여 사용합니다. LLaMA 모델을 예로 들면, 16B 파라미터 모델의 경우 192개의 GPU에서 4-way 텐서 병렬화를 사용하여 훈련할 수 있습니다. 이 경우 각 GPU는 약 4096개의 토큰을 처리하게 되며, 배치 크기는 충분히 크기 때문에 효율적인 훈련이 가능합니다.

70B 파라미터 모델의 경우, 768개의 GPU에서 2-way 텐서 병렬화를 사용하여 각 GPU당 2048개의 토큰을 처리합니다. 314B 파라미터 모델에서는 3072개의 GPU에서 8-way 텐서 병렬화를 사용하여 마찬가지로 각 GPU당 2048개의 토큰을 처리합니다. 이러한 구성에서 중요한 것은 네트워크 계층에서의 bottleneck을 피하는 것입니다.

### 메모리 최적화와 Activation Checkpointing

대규모 모델 훈련에서 메모리 사용량은 critical한 제약사항입니다. **Activation checkpointing**은 forward pass에서 모든 activation을 저장하는 대신 일부만 저장하고, backward pass에서 필요할 때 재계산하는 기법입니다. 이를 통해 메모리 사용량을 $O(\sqrt{L})$로 줄일 수 있습니다 (여기서 $L$은 레이어 수).

메모리 사용량과 계산 시간 사이의 trade-off는 다음과 같이 모델링할 수 있습니다:

$$\text{Total Time} = \text{Compute Time} \times (1 + \alpha \cdot \text{Recompute Ratio})$$

여기서 $\alpha$는 recomputation의 상대적 비용을 나타내는 상수입니다. 최적의 checkpointing 전략은 이 trade-off를 최소화하는 것입니다.

### Gradient Accumulation과 Mixed Precision

대규모 모델에서는 메모리 제약으로 인해 원하는 만큼 큰 배치 크기를 사용하기 어려운 경우가 많습니다. **Gradient accumulation**은 여러 개의 micro-batch에 대한 gradient를 누적한 후 한 번에 업데이트하는 기법으로, 실질적으로 큰 배치 크기의 효과를 얻을 수 있습니다.

**Mixed precision training**은 fp16 또는 bf16을 사용하여 메모리 사용량과 계산 시간을 줄이는 기법입니다. H100에서 bf16은 fp32에 비해 2배 빠른 성능을 제공하며, 메모리 사용량도 절반으로 줄일 수 있습니다. 하지만 수치적 안정성을 위해 loss scaling이나 gradient clipping 같은 기법이 필요할 수 있습니다.

## Blackwell(B200) 아키텍처의 혁신

### NVLink 5와 확장된 네트워킹

Blackwell 아키텍처는 여러 가지 중요한 개선사항을 도입했습니다. **NVLink 5**는 전체 NVLink 대역폭을 900GB/s로 두 배 증가시켰으며, B200은 여전히 8-GPU 노드를 유지하지만 GB200 시스템은 훨씬 큰 NVLink 도메인을 도입했습니다. NVL72 구성에서는 72개의 GPU가, 이론적으로는 최대 576개의 GPU까지 하나의 NVLink 도메인에 포함될 수 있습니다.

이러한 확장된 NVLink 도메인은 노드 egress 대역폭을 효과적으로 증가시켜 노드 레벨 이상에서의 collective 비용을 줄입니다. GB200 NVL72에서 노드당 egress 대역폭은 $4 \times 18 \times 400 / 8 = 3.6TB/s$로 증가하여, H100의 400GB/s에 비해 크게 개선됩니다. 이는 cross-node roofline을 약 4배 개선시키며, 이제 노드 레벨에서의 bottleneck이 scale-out 레벨보다 더 중요해질 수 있습니다.

### Grace-Hopper 통합과 CPU-GPU 협력

NVIDIA는 또한 GH200과 GB200 시스템에서 GPU를 Grace CPU와 결합했습니다. 예를 들어, GH200은 1개의 H200과 1개의 Grace CPU를 가지고 있으며, GB200 시스템은 2개의 B200과 1개의 Grace CPU를 가지고 있습니다. 이 시스템의 장점은 CPU가 **NVLink C2C**라는 full bandwidth NVLink 연결을 통해 GPU와 연결되어 있어, 매우 높은 CPU-GPU 대역폭을 제공한다는 것입니다. 이는 파라미터를 호스트 RAM으로 오프로딩하는 데 유용하며, 각 GPU에서 호스트 메모리에 접근하는 대역폭이 다른 GPU의 HBM에 접근하는 대역폭과 동일합니다.

### TMEM과 대형 텐서 코어의 도전

B200에서 도입된 가장 중요한 변화 중 하나는 **TMEM(Tensor Memory)**의 추가입니다. 텐서 코어가 계속 커지면서 Blackwell에서는 텐서 코어의 입력 데이터가 더 이상 SMEM에 맞지 않게 되었습니다. Ampere에서는 텐서 코어가 single warp에서 공급될 수 있었지만, Hopper에서는 full SM(warpgroup)이 필요하고, Blackwell에서는 2개의 SM에서 공급되어야 합니다. 행렬 곱셈이 너무 커져서 accumulator가 더 이상 register memory나 SMEM에 맞지 않기 때문에 Blackwell은 이를 위해 TMEM을 추가했습니다.

## 성능 프로파일링과 최적화 전략

### Roofline 모델을 통한 성능 분석

GPU 기반 ML 시스템의 성능을 분석하는 가장 효과적인 방법 중 하나는 **roofline 모델**을 사용하는 것입니다. 이 모델은 arithmetic intensity(메모리에서 읽은 바이트당 FLOP 수)에 따라 시스템이 compute bound인지 memory bound인지를 보여줍니다. H100의 경우 peak performance는 990 TFLOP/s (bf16)이고 memory bandwidth는 3.35TB/s이므로, roofline의 기울기는 다음과 같습니다:

$$\text{Roofline Slope} = \frac{990 \times 10^{12}}{3.35 \times 10^{12}} = 295 \text{ FLOP/byte}$$

이는 295 FLOP/byte보다 낮은 arithmetic intensity를 가진 연산은 memory bound가 되고, 높은 연산은 compute bound가 됨을 의미합니다. 대부분의 transformer 레이어에서 행렬 곱셈은 충분히 높은 arithmetic intensity를 가지므로 compute bound이지만, activation function이나 normalization 같은 연산은 memory bound가 될 수 있습니다.

### 실제 성능 측정과 병목지점 식별

이론적인 분석 외에도 실제 성능 측정이 중요합니다. GPU에서는 **NVIDIA Nsight Systems**나 **NVIDIA Nsight Compute** 같은 프로파일링 도구를 사용하여 실제 성능을 측정할 수 있습니다. 이러한 도구들은 커널 실행 시간, 메모리 대역폭 활용도, 통신 시간 등을 상세히 분석할 수 있게 해줍니다.

특히 대규모 분산 훈련에서는 다음과 같은 지표들을 모니터링해야 합니다:
- GPU 활용도 (compute utilization)
- 메모리 대역폭 활용도
- 네트워크 대역폭 활용도  
- 파이프라인 버블 비율
- Load balancing 효율성

이러한 지표들을 통해 시스템의 병목지점을 식별하고 최적화할 수 있습니다.

### 자동 최적화와 적응적 전략

현대의 ML 프레임워크들은 점차 자동 최적화 기능을 제공하고 있습니다. **Auto-sharding**은 주어진 모델과 클러스터 구성에 대해 최적의 병렬화 전략을 자동으로 찾는 기술입니다. 이는 다양한 병렬화 조합의 cost model을 구축하고, 각각의 예상 성능을 비교하여 최적의 전략을 선택합니다.

$$\text{Total Cost} = \text{Compute Cost} + \text{Communication Cost} + \text{Memory Cost}$$

각 비용 요소는 다음과 같이 모델링됩니다:
- Compute Cost: FLOPs / GPU throughput
- Communication Cost: Communication volume / Network bandwidth  
- Memory Cost: Memory footprint에 따른 제약

이러한 자동 최적화는 특히 복잡한 모델 아키텍처나 heterogeneous 클러스터에서 매우 유용합니다.

## 미래 방향과 기술적 도전과제

### 메모리 중심 컴퓨팅으로의 전환

GPU 아키텍처는 점차 메모리 중심 컴퓨팅으로 진화하고 있습니다. 모델 크기가 지속적으로 증가하면서 메모리 용량과 대역폭이 더욱 중요해지고 있으며, 이는 **Near-Data Computing**이나 **Processing-in-Memory** 같은 새로운 아키텍처로 이어질 수 있습니다. 또한 **Unified Memory Architecture**를 통해 CPU와 GPU 메모리 공간을 통합하려는 시도도 계속되고 있습니다.

특히 대규모 언어 모델에서는 KV-cache의 크기가 매우 커지고 있어, 이를 효율적으로 관리하는 것이 중요한 도전과제가 되고 있습니다. **Paged Attention**이나 **Ring Attention** 같은 새로운 attention 메커니즘들이 이러한 문제를 해결하기 위해 개발되고 있습니다.

### 네트워킹 기술의 발전

네트워킹 기술도 빠르게 발전하고 있습니다. **Optical interconnects**는 전기적 연결보다 훨씬 높은 대역폭과 낮은 지연시간을 제공할 수 있으며, **Photonic computing**은 전력 효율성을 크게 개선할 수 있습니다. 또한 **Disaggregated computing** 아키텍처에서는 compute, memory, storage가 네트워크를 통해 분리되어 더욱 유연한 자원 할당이 가능해질 것입니다.

네트워크 레벨에서는 **Adaptive routing**이나 **Congestion control** 같은 기술들이 대규모 클러스터에서의 통신 효율성을 개선하고 있습니다. 특히 **In-network computing**을 통해 네트워크 스위치에서 직접 aggregation이나 reduction 연산을 수행하는 것이 더욱 보편화될 것으로 예상됩니다.

### 소프트웨어 스택의 진화

GPU 소프트웨어 스택도 계속 진화하고 있습니다. **Compiler optimization**은 더욱 정교해지고 있으며, **Graph-level optimization**을 통해 전체 모델의 execution graph를 최적화할 수 있습니다. **Dynamic batching**이나 **Speculative execution** 같은 기술들은 GPU 활용도를 더욱 높일 수 있습니다.

또한 **Heterogeneous computing**이 더욱 중요해지면서, CPU, GPU, specialized accelerator들을 효율적으로 조합하는 기술들이 발전하고 있습니다. 이는 각 workload의 특성에 따라 최적의 처리 장치를 동적으로 선택하는 것을 가능하게 합니다.

## 결론: GPU 스케일링의 현재와 미래

Google DeepMind의 JAX 스케일링 가이드는 현대 GPU 기반 ML 시스템의 복잡성과 최적화 전략에 대한 깊이 있는 통찰을 제공합니다. H100부터 B200까지의 하드웨어 진화는 단순한 성능 향상을 넘어 아키텍처의 근본적인 변화를 보여주며, 이는 소프트웨어 최적화 전략에도 큰 영향을 미치고 있습니다.

특히 주목할 점은 메모리 계층구조의 복잡성이 증가하고 있다는 것입니다. TMEM의 도입은 텐서 코어가 계속 커지면서 기존 메모리 계층으로는 감당할 수 없게 되었음을 보여주며, 이는 향후 GPU 아키텍처 설계에서 메모리 관리가 더욱 중요해질 것임을 시사합니다. 또한 NVLink 도메인의 확장은 더 큰 규모의 tight coupling을 가능하게 하여, 대규모 모델 훈련의 새로운 가능성을 열어주고 있습니다.

네트워킹 측면에서는 hierarchical 구조의 복잡성이 증가하고 있으며, 이는 병렬화 전략 선택에 더욱 정교한 분석이 필요함을 의미합니다. 특히 데이터 병렬화, 텐서 병렬화, 파이프라인 병렬화, expert 병렬화의 최적 조합을 찾는 것은 단순한 heuristic을 넘어 체계적인 cost model과 자동 최적화가 필요한 영역이 되었습니다.

미래의 GPU 시스템은 더욱 heterogeneous해질 것으로 예상되며, CPU-GPU 통합, 메모리 중심 컴퓨팅, optical interconnect 등의 기술들이 결합되어 현재보다 훨씬 복잡하지만 강력한 시스템을 만들어낼 것입니다. 이러한 환경에서 성공하기 위해서는 하드웨어 아키텍처에 대한 깊은 이해와 함께 adaptive한 소프트웨어 최적화 전략이 필수적일 것입니다.

결국 GPU 스케일링의 미래는 단순한 성능 향상을 넘어, 효율성, 유연성, 그리고 지속가능성을 모두 고려한 holistic한 접근이 요구되는 영역으로 발전하고 있습니다. 이러한 변화는 ML 엔지니어들에게 새로운 도전과 기회를 동시에 제공하며, 지속적인 학습과 적응이 필요한 rapidly evolving landscape를 만들어가고 있습니다.
