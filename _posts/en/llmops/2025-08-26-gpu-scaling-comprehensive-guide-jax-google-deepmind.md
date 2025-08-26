---
title: "Deep Understanding of GPU Scaling: Google DeepMind JAX Scaling Guide Analysis"
excerpt: "From NVIDIA GPU architecture to networking and large language model training - comprehensive theoretical analysis for performance optimization of GPU-based ML systems"
seo_title: "GPU Scaling Guide: H100/B200 Architecture and LLM Training Optimization - Thaki Cloud"
seo_description: "In-depth analysis from NVIDIA H100, B200 hardware architecture to networking and large-scale language model parallel processing based on Google DeepMind's GPU scaling guide"
date: 2025-08-26
categories:
  - llmops
tags:
  - GPU-Scaling
  - NVIDIA-H100
  - NVIDIA-B200
  - LLM-Training
  - Tensor-Parallelism
  - Data-Parallelism
  - JAX
  - Google-DeepMind
author_profile: true
toc: true
toc_label: "Table of Contents"
canonical_url: "https://thakicloud.github.io/en/llmops/gpu-scaling-comprehensive-guide-jax-google-deepmind/"
lang: en
permalink: /en/llmops/gpu-scaling-comprehensive-guide-jax-google-deepmind/
---

⏱️ **Estimated Reading Time**: 25 minutes

## Introduction: Modern Understanding of GPU Scaling

In contemporary machine learning systems, GPUs have evolved beyond simple graphics processing units to become the core infrastructure for large language model training and inference. [Google DeepMind's JAX Scaling Guide](https://jax-ml.github.io/scaling-book/gpus/) provides profound insights into performance optimization of GPU-based ML systems, particularly offering systematic analysis of large language model training strategies on cutting-edge GPU architectures like NVIDIA H100 and B200. This article presents a detailed, paragraph-by-paragraph analysis of the guide's core content, comprehensively examining everything from fundamental GPU hardware structures to networking approaches and practical parallelization strategies in LLM training.

## In-Depth Analysis of GPU Hardware Architecture

### Fundamental Structure: Harmony Between Streaming Multiprocessors and HBM

Modern machine learning GPUs such as H100 and B200 can essentially be understood as structures where numerous computing cores specialized in matrix multiplication are connected to high-speed memory. These computing cores are called **Streaming Multiprocessors (SMs)** and are connected to **HBM (High Bandwidth Memory)**. The H100 contains 132 SMs while the B200 has 148 SMs, providing significantly more independent processing units compared to TPUs. This structural characteristic is the fundamental reason why GPUs can offer higher levels of flexibility than TPUs.

Each SM includes a dedicated matrix multiplication core called **Tensor Core**, a vector arithmetic unit called **Warp Scheduler**, and high-speed on-chip cache called **SMEM**, similar to TPU's tensor cores. Particularly noteworthy is that while TPUs have at most 2 independent tensor cores, modern GPUs possess over 100 SMs. Although each SM's performance is relatively lower compared to TPU's tensor cores, the overall system flexibility is much higher. This is because each SM can operate independently, enabling GPUs to simultaneously process hundreds of separate tasks.

### Internal SM Structure: Subpartitions and Processing Units

Examining the internal structure of H100 SM in detail reveals that each SM is divided into 4 identical subpartitions, with each subpartition containing a tensor core, 16K 32-bit registers, and a SIMD/SIMT vector arithmetic unit called warp scheduler. The individual ALUs of the warp scheduler are called **CUDA cores**, and while the core component of each subpartition is arguably the tensor core that handles most FLOP/s, other components also play important roles.

**CUDA cores** are sets of ALUs included in each subpartition, responsible for SIMD/SIMT vector arithmetic. Each ALU can generally perform one arithmetic operation per cycle, such as f32.add operations. Newer GPUs support FMA (Fused-Multiply Add) instructions that technically perform two FLOPs per cycle, which NVIDIA often uses to double their nominal performance specifications. Each subpartition contains 32 fp32 cores and smaller numbers of int32 and fp64 cores, all executing the same instruction in each cycle.

**Tensor Cores** are deployed one per subpartition and serve as dedicated matrix multiplication units like TPU's MXU. Tensor cores account for the overwhelming majority of GPU FLOP/s; for example, in H100, they provide 990 bf16 TC TFLOP/s compared to just 66 TFLOP/s from CUDA cores. In H100 with 132 SMs operating at 1.76GHz, each tensor core can perform approximately 1024 bf16 FLOPs per cycle, roughly equivalent to an 8×8×8 matrix multiplication.

### Architectural Comparison: GPU vs TPU Analysis

CUDA cores have much more flexible structures than TPU's VPU. GPU CUDA cores since V100 use the SIMT (Single Instruction Multiple Threads) programming model, while TPUs use the SIMD (Single Instruction Multiple Data) model. Like ALUs in TPU's VPU, CUDA cores within a subpartition must execute the same operation in each cycle, but unlike TPUs, each CUDA core has its own instruction pointer and can be programmed independently. When two threads in the same warp are instructed to perform different operations, both operations are effectively executed while masking out cores that don't need to perform the divergent operation.

## Memory Hierarchy and Performance Characteristics

### HBM and Memory Bandwidth Analysis

GPU memory systems have absolute impact on performance. H100 provides 80GB of HBM3 memory with 3.35TB/s bandwidth, while B200 offers 192GB of HBM3e memory with 8TB/s bandwidth. This represents significant improvement compared to TPU v5p's 95GB HBM2e with 2.76TB/s bandwidth. Particularly, B200's increased memory capacity and bandwidth enable more efficient processing of large language model parameters.

What's important in memory hierarchy is the bandwidth and latency at each level. L2 cache is 40MB in size and shared across the entire GPU, while each SM's SMEM is 256KB. In B200, tensor cores have become so large that input data no longer fits in SMEM, leading to the introduction of a new memory space called **TMEM (Tensor Memory)**. This change in memory hierarchy demonstrates that tensor core sizes continue to increase with each GPU generation.

### Compute vs Memory Bound Analysis

GPU performance is often determined by whether it's compute bound or memory bound. While H100 provides 990 TFLOP/s performance for bf16 operations, memory bandwidth is limited to 3.35TB/s. This can be analyzed using the concept of **arithmetic intensity**, which represents the number of operations performed per byte read from memory.

$$\text{Arithmetic Intensity} = \frac{\text{FLOP}}{\text{Bytes Accessed}}$$

The boundary between memory bound and compute bound on H100 is calculated approximately as:

$$\text{Peak AI} = \frac{990 \times 10^{12} \text{ FLOP/s}}{3.35 \times 10^{12} \text{ B/s}} \times 2 \text{ bytes/bf16} = 591 \text{ FLOP/byte}$$

Operations with arithmetic intensity lower than this value become memory bound, while those with higher values become compute bound.

## Networking Architecture and Scaling Strategies

### Node-Level Networking: NVLink and NVSwitch

Communication between GPUs has critical impact on performance and can be analyzed at two levels: within nodes and between nodes. Within nodes, GPUs are connected through NVLink and NVSwitch. In H100 DGX nodes, 8 GPUs are connected through 4 NVSwitches, with each GPU having 18 NVLink 4.0 connections. Each NVLink provides 50GB/s bidirectional bandwidth, so theoretically each GPU could have 900GB/s total bandwidth, but is actually limited to 450GB/s due to NVSwitch bandwidth constraints.

NVSwitch is a centralized crossbar switch with 64 NVLink ports providing 1.6TB/s total bandwidth. In nodes with 8 GPUs, each GPU actually has 450GB/s egress bandwidth, which is the bandwidth for communicating with other GPUs in the same node. This structure makes tensor parallelization and pipeline parallelization within nodes extremely efficient.

### Inter-Node Networking: InfiniBand and Hierarchical Structure

Inter-node communication occurs through InfiniBand networks, typically using leaf-spine topology. In H100 SuperPod cases, each node has 8 400Gbps InfiniBand connections providing 3.2TB/s total bidirectional bandwidth. However, it's actually limited to 50GB/s inter-node bandwidth per GPU. This is 9 times lower than the intra-node bandwidth of 450GB/s, explaining why minimizing inter-node communication is important in large-scale model training.

SuperPod architecture has hierarchical structure, divided into **Scalable Unit (SU)** level and **spine** level. At SU level, 32 nodes (256 GPUs) are connected through 8 leaf switches, and multiple SUs are connected through 16 spine switches. This hierarchical structure has bandwidth limitations at each level, particularly being further limited to 25GB/s per GPU at the spine level.

### Relationship Between Network Bandwidth and Parallelization Strategies

Network bandwidth limitations directly impact the efficiency of various parallelization strategies. **Data parallelization** requires AllReduce operations for gradient synchronization, making it very sensitive to network bandwidth. **Tensor parallelization** requires continuous inter-GPU communication during forward and backward passes, demanding high bandwidth. **Pipeline parallelization** requires relatively less communication but needs activation transfers between pipeline stages.

$$\text{Communication Cost} = \frac{\text{Data Size}}{\text{Bandwidth}} + \text{Latency}$$

In this equation, Data Size is the size of data to be transmitted, Bandwidth is available network bandwidth, and Latency is network latency. In large-scale model training, since Data Size is very large, the Bandwidth term becomes dominant, significantly influencing network topology and parallelization strategy selection.

## Performance Analysis of Collective Operations

### Characteristics of AllReduce and AllGather Operations

The most important communication patterns in large-scale distributed training are collective operations. **AllReduce** is an operation that sums gradients from all GPUs and distributes identical results to all GPUs, playing a key role in data parallelization. **AllGather** is an operation that collects data from each GPU to all GPUs, frequently used in tensor parallelization. **ReduceScatter** is the reverse operation of AllReduce, summing data then partitioning and distributing it.

Performance of these operations within nodes is very high. For AllReduce in 8-GPU H100 nodes, latency dominates for small message sizes, but bandwidth becomes dominant for large message sizes. According to actual measurements, messages above 256MB can achieve 80-90% of theoretical bandwidth performance. This means that intra-node tensor parallelization is very efficient.

### Challenges of Inter-Node Collective Operations

Inter-node collective operations are much more complex and have significant performance constraints. AllReduce in hierarchical network structures is typically implemented using **hierarchical AllReduce** approach. First, AllReduce is performed within each node, then the results are AllReduced between nodes, followed by broadcasting within nodes again. The total time for this process can be modeled as:

$$T_{AllReduce} = T_{intra} + T_{inter} + T_{broadcast}$$

Where $T_{intra}$ is intra-node AllReduce time, $T_{inter}$ is inter-node AllReduce time, and $T_{broadcast}$ is intra-node broadcast time. In practice, $T_{inter}$ often becomes dominant because inter-node bandwidth is much lower than intra-node bandwidth.

### SHARP and In-Network Computing

NVIDIA introduced **SHARP (Scalable Hierarchical Aggregation and Reduction Protocol)** technology to improve network performance. SHARP is technology that performs reduction operations directly in InfiniBand switches to reduce network traffic. This can theoretically improve AllReduce operation bandwidth by up to 2x. However, SHARP is only activated under specific conditions and cannot be used in all situations.

$$\text{SHARP Efficiency} = \frac{\text{Actual Bandwidth}}{\text{Theoretical Bandwidth}}$$

In actual measurements, when SHARP is activated, it shows 70-80% efficiency, but when deactivated, it shows only 40-50% efficiency. This performance difference demonstrates that SHARP optimization is very important in large-scale training.

## Parallelization Strategies for Large Language Models

### Data Parallelization and Roofline Analysis

Data parallelization is the most basic distributed training method where each GPU holds a complete copy of the model and processes different batches of data. The main constraint of this method is AllReduce operations for gradient synchronization. When batch size per GPU is $B$ and model parameter count is $P$, the data size to be AllReduced is $2P$ bytes (for fp16).

The roofline for data parallelization is calculated as:

$$\text{Compute Time} = \frac{6PBS}{F}$$
$$\text{Communication Time} = \frac{2P}{BW}$$

Where $S$ is sequence length, $F$ is FLOP/s, and $BW$ is AllReduce bandwidth. For efficient data parallelization, Communication Time must be smaller than Compute Time, so:

$$B > \frac{PF}{3SBWO}$$

In this equation, $O$ represents a constant for network overhead. For inter-node communication on H100, this threshold becomes quite high.

### Efficiency Analysis of Tensor Parallelization

Tensor parallelization is a method of partitioning model weight matrices across multiple GPUs, particularly effective for attention mechanisms and MLP layers. Each head in multi-head attention can be placed on different GPUs, or MLP weight matrices can be partitioned row-wise or column-wise. The main advantage of tensor parallelization is linear reduction in GPU memory usage, while the disadvantage is continuous communication required during forward and backward passes.

Communication cost in tensor parallelization is proportional to activation size. In a transformer with batch size $B$, sequence length $S$, and hidden dimension $H$, each attention layer requires the following communication:

$$\text{Communication Volume} = 4BSH \text{ bytes}$$

This consists of 2 AllGathers in forward pass and 2 ReduceScatters in backward pass. For tensor parallelization to be efficient, this communication time must be smaller than computation time.

### Pipeline Parallelization and Memory Efficiency

Pipeline parallelization is a method of sequentially placing model layers across multiple GPUs. This method can effectively reduce memory usage but may cause GPU idle time due to pipeline bubbles. Pipeline parallelization efficiency is determined by the ratio of micro-batch count to pipeline stage count.

Pipeline efficiency can be calculated as:

$$\text{Pipeline Efficiency} = \frac{M}{M + P - 1}$$

Where $M$ is the number of micro-batches and $P$ is the number of pipeline stages. For high efficiency, $M \gg P$ is required, but if micro-batch size is too small, each GPU's utilization may decrease.

### Expert Parallelization and Mixture of Experts

In Mixture of Experts (MoE) models, since each token activates only a few experts, a special form of parallelization called expert parallelization is needed. Each expert is placed on different GPUs, and input tokens are routed to GPUs containing appropriate experts. In this process, **AllToAll** collective operations play a key role.

Communication cost in expert parallelization heavily depends on the imbalance of expert utilization. In ideal cases where all experts are used equally, communication cost is:

$$\text{AllToAll Cost} = \frac{BSH \cdot k}{E} \cdot 2$$

Where $k$ is the number of experts activated per token and $E$ is the total number of experts. However, in practice, communication cost may increase due to load imbalance between experts.

## Optimization Strategies in Actual Model Training

### LLaMA Model Training Case Analysis

In actual large language model training, multiple parallelization techniques are used in combination. Taking LLaMA models as an example, a 16B parameter model can be trained using 4-way tensor parallelization on 192 GPUs. In this case, each GPU processes approximately 4096 tokens, and since batch size is sufficiently large, efficient training is possible.

For 70B parameter models, 2-way tensor parallelization is used on 768 GPUs, with each GPU processing 2048 tokens. For 314B parameter models, 8-way tensor parallelization is used on 3072 GPUs, similarly processing 2048 tokens per GPU. What's important in these configurations is avoiding bottlenecks at network layers.

### Memory Optimization and Activation Checkpointing

Memory usage is a critical constraint in large-scale model training. **Activation checkpointing** is a technique that stores only some activations during forward pass instead of all, and recomputes them when needed during backward pass. This can reduce memory usage to $O(\sqrt{L})$ where $L$ is the number of layers.

The trade-off between memory usage and computation time can be modeled as:

$$\text{Total Time} = \text{Compute Time} \times (1 + \alpha \cdot \text{Recompute Ratio})$$

Where $\alpha$ is a constant representing the relative cost of recomputation. The optimal checkpointing strategy minimizes this trade-off.

### Gradient Accumulation and Mixed Precision

In large-scale models, it's often difficult to use desired large batch sizes due to memory constraints. **Gradient accumulation** is a technique that accumulates gradients from multiple micro-batches before updating once, effectively achieving the effect of large batch sizes.

**Mixed precision training** is a technique using fp16 or bf16 to reduce memory usage and computation time. Bf16 on H100 provides 2x faster performance compared to fp32 and can halve memory usage. However, techniques like loss scaling or gradient clipping may be needed for numerical stability.

## Innovations in Blackwell (B200) Architecture

### NVLink 5 and Extended Networking

Blackwell architecture introduced several important improvements. **NVLink 5** doubled total NVLink bandwidth to 900GB/s, and while B200 still maintains 8-GPU nodes, GB200 systems introduce much larger NVLink domains. In NVL72 configuration, 72 GPUs can be included, and theoretically up to 576 GPUs can be in a single NVLink domain.

This extended NVLink domain effectively increases node egress bandwidth, reducing collective costs above node level. In GB200 NVL72, egress bandwidth per node increases to $4 \times 18 \times 400 / 8 = 3.6TB/s$, significantly improved from H100's 400GB/s. This improves cross-node rooflines by approximately 4x, and now node-level bottlenecks may become more important than scale-out level.

### Grace-Hopper Integration and CPU-GPU Cooperation

NVIDIA also combined GPUs with Grace CPUs in GH200 and GB200 systems. For example, GH200 has 1 H200 and 1 Grace CPU, while GB200 systems have 2 B200s and 1 Grace CPU. The advantage of this system is that CPUs are connected to GPUs through **NVLink C2C**, a full bandwidth NVLink connection, providing very high CPU-GPU bandwidth. This is useful for offloading parameters to host RAM, where bandwidth from each GPU to host memory equals bandwidth to another GPU's HBM.

### TMEM and Challenges of Large Tensor Cores

One of the most important changes introduced in B200 is the addition of **TMEM (Tensor Memory)**. As tensor cores continue to grow larger, in Blackwell, tensor core input data no longer fits in SMEM. While in Ampere, tensor cores could be fed from a single warp, Hopper requires a full SM (warpgroup), and Blackwell requires feeding from 2 SMs. Matrix multiplications have become so large that accumulators no longer fit in register memory or SMEM, so Blackwell added TMEM for this purpose.

## Performance Profiling and Optimization Strategies

### Performance Analysis Through Roofline Models

One of the most effective ways to analyze GPU-based ML system performance is using **roofline models**. This model shows whether a system is compute bound or memory bound based on arithmetic intensity (FLOP count per byte read from memory). For H100 with peak performance of 990 TFLOP/s (bf16) and memory bandwidth of 3.35TB/s, the roofline slope is:

$$\text{Roofline Slope} = \frac{990 \times 10^{12}}{3.35 \times 10^{12}} = 295 \text{ FLOP/byte}$$

This means operations with arithmetic intensity lower than 295 FLOP/byte become memory bound, while higher operations become compute bound. Most transformer layer matrix multiplications have sufficiently high arithmetic intensity to be compute bound, but operations like activation functions or normalization may be memory bound.

### Actual Performance Measurement and Bottleneck Identification

Beyond theoretical analysis, actual performance measurement is important. On GPUs, profiling tools like **NVIDIA Nsight Systems** or **NVIDIA Nsight Compute** can be used to measure actual performance. These tools enable detailed analysis of kernel execution time, memory bandwidth utilization, communication time, etc.

Particularly in large-scale distributed training, the following metrics should be monitored:
- GPU utilization (compute utilization)
- Memory bandwidth utilization
- Network bandwidth utilization
- Pipeline bubble ratio
- Load balancing efficiency

These metrics help identify system bottlenecks and optimize them.

### Automatic Optimization and Adaptive Strategies

Modern ML frameworks increasingly provide automatic optimization features. **Auto-sharding** is technology that automatically finds optimal parallelization strategies for given models and cluster configurations. This builds cost models for various parallelization combinations and compares expected performance of each to select optimal strategies.

$$\text{Total Cost} = \text{Compute Cost} + \text{Communication Cost} + \text{Memory Cost}$$

Each cost component is modeled as:
- Compute Cost: FLOPs / GPU throughput
- Communication Cost: Communication volume / Network bandwidth
- Memory Cost: Constraints based on memory footprint

Such automatic optimization is particularly useful for complex model architectures or heterogeneous clusters.

## Future Directions and Technical Challenges

### Transition to Memory-Centric Computing

GPU architecture is gradually evolving toward memory-centric computing. As model sizes continue to increase, memory capacity and bandwidth become increasingly important, potentially leading to new architectures like **Near-Data Computing** or **Processing-in-Memory**. Attempts to unify CPU and GPU memory spaces through **Unified Memory Architecture** also continue.

Particularly in large language models, KV-cache sizes are becoming very large, making efficient management an important challenge. New attention mechanisms like **Paged Attention** or **Ring Attention** are being developed to solve these problems.

### Advances in Networking Technology

Networking technology is also rapidly advancing. **Optical interconnects** can provide much higher bandwidth and lower latency than electrical connections, and **Photonic computing** can significantly improve power efficiency. In **Disaggregated computing** architectures, compute, memory, and storage are separated through networks, enabling more flexible resource allocation.

At the network level, technologies like **Adaptive routing** or **Congestion control** are improving communication efficiency in large-scale clusters. Particularly, **In-network computing** that performs aggregation or reduction operations directly in network switches is expected to become more common.

### Evolution of Software Stack

GPU software stack continues to evolve. **Compiler optimization** is becoming more sophisticated, and **Graph-level optimization** can optimize entire model execution graphs. Technologies like **Dynamic batching** or **Speculative execution** can further increase GPU utilization.

As **Heterogeneous computing** becomes more important, technologies for efficiently combining CPUs, GPUs, and specialized accelerators are advancing. This enables dynamic selection of optimal processing devices based on each workload's characteristics.

## Conclusion: Present and Future of GPU Scaling

Google DeepMind's JAX scaling guide provides deep insights into the complexity and optimization strategies of modern GPU-based ML systems. The hardware evolution from H100 to B200 demonstrates fundamental architectural changes beyond simple performance improvements, significantly impacting software optimization strategies.

Particularly noteworthy is the increasing complexity of memory hierarchy. The introduction of TMEM shows that tensor cores have grown so large that existing memory hierarchies can no longer handle them, suggesting that memory management will become even more important in future GPU architecture design. Additionally, the expansion of NVLink domains enables larger-scale tight coupling, opening new possibilities for large-scale model training.

From a networking perspective, the complexity of hierarchical structures is increasing, meaning more sophisticated analysis is needed for parallelization strategy selection. Particularly, finding optimal combinations of data parallelization, tensor parallelization, pipeline parallelization, and expert parallelization has become an area requiring systematic cost models and automatic optimization beyond simple heuristics.

Future GPU systems are expected to become increasingly heterogeneous, with technologies like CPU-GPU integration, memory-centric computing, and optical interconnects combining to create systems that are more complex but more powerful than current ones. To succeed in such environments, deep understanding of hardware architecture along with adaptive software optimization strategies will be essential.

Ultimately, the future of GPU scaling is evolving into an area requiring holistic approaches that consider efficiency, flexibility, and sustainability beyond simple performance improvements. These changes provide both new challenges and opportunities for ML engineers, creating a rapidly evolving landscape that requires continuous learning and adaptation.
