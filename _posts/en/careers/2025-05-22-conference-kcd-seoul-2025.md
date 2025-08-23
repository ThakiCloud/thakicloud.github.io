---
title: "[Thaki Cloud Life & Career] KCD Seoul 2025"
excerpt: "Sharing materials presented at KCD Seoul 2025. Content about Thaki Cloud, an xPU as a Service-based Agentic AI platform"
date: 2025-05-22
categories:
  - careers
tags:
  - Thaki Cloud
  - Introduction
  - Company Culture
  - Careers
  - Recruitment
  - Developer Story
  - Team
author_profile: true
lang: en
permalink: /en/careers/conference-kcd-seoul-2025/
canonical_url: "https://thakicloud.github.io/en/careers/conference-kcd-seoul-2025/"
--- 

# 🎤 ThakiCloud @ KCD Seoul 2025 Presentation Information

---

## 📅 Date

**May 22, 2025 (Thursday)**

---

## 🔗 Related Links

- **Official Website**: [KCD Seoul 2025](https://community.cncf.io/events/details/cncf-kcd-south-korea-presents-kcd-seoul-2025/)
- **LinkedIn Promotion Page**: [ThakiCloud - KCD Seoul 2025](https://www.linkedin.com/posts/thakicloud_kcdseoul2025-thakicloud-xpuasaservice-activity-7330146553937960961-yBcG?utm_source=share&utm_medium=member_desktop&rcm=ACoAAAAuzrMB15I-NYSyIEDIpkgrPxOMdfaqjcM)
- **Presentation Materials**: [View Slides](https://ihryedku.gensparkspace.com/)

---

## 📜 Presentation Script

### 🎤 ThakiCloud Introduction and xPU-based Agentic AI Infrastructure Platform

---

### 1. Intro (Slide 1)

Hello. I'm [Name] from ThakiCloud.  
Today, I'll talk about the **Kubernetes-Native Agentic AI Platform** that changes the infrastructure paradigm of the AI era, and **the future of xPU-based AI infrastructure** that we propose.

---

### 2. Company Introduction & Mission (Slide 2)

ThakiCloud is an AI infrastructure platform company that realizes the flexibility and scalability of public cloud level in **private and hybrid environments**.

**Mission**: Supporting all companies to transform to AI First

**Core Technology Areas**:

- LLM & Agentic AI Infrastructure  
- Heterogeneous accelerator integrated management (xPU management)  
- Kubernetes-Native based xPU servitization  

---

### 3. Why xPUaaS and Agentic AI? (Slide 3)

**Current Problems**:

- GPU-centered cost (TCO) increase and supply chain instability  
- Difficulty in hardware optimization according to various workloads  
- Complex orchestration unique to Agentic AI  
- Data sovereignty issues  

**ThakiCloud's Solutions**:

- **xPUaaS** providing various accelerators as services  
- **Turnkey Agentic AI PaaS** centered on developer experience  
- Data regulation response through **Sovereign Cloud**  

---

### 4. AI Workload Optimization Flow (Slide 4)

Looking at the diagram, our platform **automatically allocates the most suitable xPU** according to AI workload types.

Examples:

- **Large-scale training** → NVIDIA GPU Cluster  
- **Real-time inference** → High-performance GPU or domestic NPU  
- **Batch inference** → Cost-optimized hybrid structure  

These pipelines are **automatically optimized through continuous monitoring and feedback**.

---

### 5. Cloud-Native AI Infrastructure Configuration (Slide 5~6)

Our xPUaaS is designed based on **Kubernetes extension architecture**:

- Various **device plugins**  
- Integrated **inference runtime**  
- Intuitive API through **xPU SDK Wrapper**  
- Monitoring environment based on **Prometheus, Grafana, Loki**  

Various clients including SDK, web, and mobile access through **API Gateway**.

---

### 🎤 Slide 6 Detailed Presentation Script

#### ✅ Overall Configuration Flow

ThakiCloud's xPUaaS architecture is a structure that **visualizes the entire flow** from client requests to inference accelerators.

#### 1. Client Layer

- Web, mobile, SDK clients access AI services through API Gateway  
- **xPUaaS API Gateway** centrally routes requests

#### 2. Core Service Layer

- **Inference Service**: Real-time inference processing  
- **Model Management**: Model registration, version management  
- **xPU Resource Pools**: Accelerator pool configuration  
- **Autoscaling**: Automatic scale adjustment according to demand

#### 3. Kubernetes Orchestration Layer

- **Device Plugins**: Register accelerators by vendor (NVIDIA, Rebellions, Furiosa, etc.)  
- **Custom Scheduler**: Optimized resource placement  
- **Inference Runtime / SDK Wrapper**: Backend integration  
- **Resource Isolation / Observability**: Build isolation and monitoring systems

#### 4. Hardware Layer

- Real-time integration with NVIDIA GPU, FuriosaAI NPU, Rebellions NPU, etc.  
- Includes driver, power, health check, firmware update management

#### 📌 Summary Emphasis

- **Single API Gateway**  
- **Kubernetes-based automated infrastructure**  
- **Flexible xPU connectivity**  
- **Strong monitoring and stability assurance**

---

### 6. Flexible Cloud Operation Strategy (Slide 8~9)

- **GitOps + Helm** based declarative deployment  
- **Multi-cloud support**: On-premises, AWS EKS, GCP GKE, Azure AKS  
- **Serverless scalability**: Integration with ACA, Cloud Run  
- Realizing **public cloud level automation and scaling** in private environments

---

### 7. Reasons to Join Us (Slide 10)

ThakiCloud:

- **Leads AI infrastructure innovation**  
- Pursues **open source contribution-centered engineer culture**  
- **Grows together with the domestic NPU ecosystem**  

We're waiting for partners and colleagues who will design the future of AI infrastructure together.

---

## 🔚 Conclusion

Thank you for listening.  
We look forward to having more conversations during the Q&A session after the presentation.
