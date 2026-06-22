---
title: "Building Sovereign AI for Air-Gapped Public Sector: On-Premises LLM Reference Architecture"
excerpt: "A guide for government and public sector organizations that cannot use external cloud services to securely operate LLMs on internal GPU infrastructure. Introduces ThakiCloud AI Platform's air-gap deployment reference architecture, along with security and governance design."
seo_title: "On-Premises LLM Reference Architecture for Air-Gapped Public Sector - Thaki Cloud"
seo_description: "Reference architecture for public sector and government organizations in air-gapped environments to build a sovereign AI cloud on-premises. Covers NIS security requirements, domestic data storage mandates, Keycloak RBAC, ArgoCD GitOps, and vLLM serverless inference."
date: 2026-06-22
last_modified_at: 2026-06-22
categories:
  - saas
tags:
  - sovereign-ai
  - on-premise
  - llm
  - air-gap
  - public-sector
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
lang: en
canonical_url: "https://thakicloud.github.io/en/saas/sovereign-ai-airgap-public-sector/"
reading_time: true
---

![Sovereign AI Reference Architecture for Air-Gapped Public Sector](/assets/images/sovereign-ai-airgap-public-sector-hero.png)

## Overview: Why Sovereign AI Matters for the Public Sector Now

Since 2024, generative AI adoption discussions have accelerated across Korean government agencies and public institutions. However, many organizations face significant barriers to using commercial cloud LLM services due to security regulations and legal requirements. Security monitoring mandates from the National Intelligence Service (NIS), domestic data storage obligations under the Information and Communications Network Act and the Personal Information Protection Act, and longstanding network separation policies all fundamentally block external API calls.

In this environment, the demand to "use AI without letting data leave the premises" converges on a single solution: operating LLMs directly on internal GPU infrastructure -- what is known as **Sovereign AI**.

ThakiCloud is a Kubernetes-based AI/ML SaaS platform designed for full deployment in on-premises and air-gapped environments. This article uses a hypothetical public sector case to present a detailed reference architecture for securely deploying LLM services in a network-separated environment.

---

## Constraints Facing Public Sector Organizations

### Network Separation and Air-Gap

The most defining characteristic of Korean public sector IT environments is the complete separation of internet networks from internal work networks. Many agencies go beyond logical separation to require physically disconnected air-gap configurations. In these cases, not only are public cloud API calls impossible -- even external access to container image registries is blocked. Every image and package required for deployment must be pre-mirrored into an internal registry.

### NIS Security Requirements

The National Intelligence Service's Cloud Security Assurance Program (CSAP) and security monitoring guidelines mandate audit log retention for system access history, multi-factor authentication (MFA), role-based access control (RBAC), and domestic storage of all sensitive data. Because inference requests to an LLM may contain query content that itself qualifies as sensitive information, inference endpoints fall within this scope of control.

### On-Premises Network Constraints

Designing service URLs for on-premises environments comes with its own unique constraints. As an established fact in this context, on-premises environments frequently cannot support wildcard DNS or wildcard SSL certificates. Service access URLs must therefore either use a pre-defined fixed subdomain pool (e.g., `api.aiplatform.agency.go.kr`, `console.aiplatform.agency.go.kr`) or distinguish services by port number on a single hostname. These constraints must be addressed at the platform design stage.

### Domestic Data Storage Mandate

Under the Public Data Management Act and the Personal Information Protection Act, data processed by public institutions must be stored on servers within South Korea. Sending LLM queries to overseas public cloud providers may itself constitute a violation of this obligation.

---

## Reference Architecture: Air-Gapped Deployment Configuration

Below is a reference architecture for a hypothetical central government agency deploying ThakiCloud AI Platform in an on-premises air-gapped environment.

```mermaid
graph TB
    subgraph "Work Network (Air-Gapped)"
        subgraph "User Layer"
            U1[Administrative Staff Terminal]
            U2[Research Staff Terminal]
        end

        subgraph "Access Control Layer"
            GW[Traefik Gateway API\nHTTP/gRPC/WebSocket]
            KC[Keycloak IdP\nOIDC/MFA/RBAC]
        end

        subgraph "Control Plane (k0s)"
            CP[Go API Server\n:3000]
            WEB[React Web Console]
            ARGO[ArgoCD GitOps]
            PG[(PostgreSQL)]
            NATS[NATS JetStream]
        end

        subgraph "Data Plane A - Inference"
            VLLM[vLLM Serverless\n+ KEDA Scale-to-Zero]
            KAI[KAI Scheduler\n+ Kueue]
            GPU1[GPU Node (MIG)]
        end

        subgraph "Data Plane B - Training"
            KF[Kubeflow TrainJob\nSFT/DPO/LoRA]
            GPU2[GPU Node (Full)]
        end

        subgraph "Observability Stack"
            VM[VictoriaMetrics]
            VL[VictoriaLogs]
            DCGM[DCGM Exporter]
        end

        subgraph "Internal Registry"
            REG[Harbor\nImage Mirror]
            GIT[Gitea\nInternal Git]
        end
    end

    U1 -->|HTTPS| GW
    U2 -->|HTTPS| GW
    GW -->|OIDC Token| KC
    GW --> WEB
    GW --> CP
    CP --> VLLM
    CP --> KF
    CP --> PG
    CP --> NATS
    ARGO --> GIT
    ARGO -->|GitOps Sync| CP
    VLLM --> KAI
    KAI --> GPU1
    KF --> GPU2
    VM --> DCGM
    VL --> VM
```

### Key Components

**Control Plane and Data Plane Separation**

According to ThakiCloud AI Platform documentation (see the logical architecture for KSA partner evaluation), the platform strictly separates the control plane from the data plane. The control plane manages API services, state, and orchestration logic, while the data plane handles GPU workload execution and inference endpoint services. This separation ensures that inference services in the data plane can continue operating without interruption even during control plane maintenance.

**Internal Registry for Air-Gap Deployment**

In environments disconnected from the external internet, an internal container registry such as Harbor must be configured and all container images pre-mirrored. Rather than the standard kubeadm, the lightweight deployment tool k0s is used for Kubernetes cluster deployment, with official support for air-gap installation. Combining Helm charts with ArgoCD's App-of-Apps pattern allows the entire cluster state to be managed declaratively, using an internal Gitea repository as the single source of truth.

**vLLM Serverless Inference and Scale-to-Zero**

Inference workloads are built on vLLM and integrated with KEDA (Kubernetes Event-Driven Autoscaler) to achieve scale-to-zero. GPU resources are released during idle periods and automatically scaled up when requests arrive, enabling efficient sharing of limited on-premises GPU resources.

---

## Security and Governance

### Four-Tier RBAC with Keycloak OIDC

ThakiCloud AI Platform provides a four-tier RBAC structure -- Organization, Project, Group, and User -- using Keycloak as the Identity Provider (IdP). According to the Web UI README, role assignments for Admin, Developer, and Viewer roles are implemented with Union+Deny algorithm-based permission merging, and group information is embedded in JWT tokens for real-time permission validation.

In the public sector context, departmental project isolation is critical. For example, even when the Planning and Coordination Office and the IT Department share the same platform, each department's LLM query history and fine-tuning data are isolated at the project namespace level to prevent cross-department exposure.

Keycloak's MFA configuration can satisfy the enhanced authentication requirements in NIS security monitoring guidelines. Integration with existing HR systems or Active Directory is also supported via LDAP federation.

### ArgoCD GitOps and Change History Management

All platform configuration changes are managed as Helm charts in an internal Git repository and synchronized to the cluster by ArgoCD. This GitOps pattern provides a complete audit trail -- who changed what and when -- through Git commit logs. It eliminates ad hoc changes from direct `kubectl apply` commands (configuration drift), enhancing the reliability of change history needed for compliance audits.

### Audit Logs and Observability Stack

Inference API calls, fine-tuning job start and end events, user logins, and permission change events are all collected centrally in VictoriaLogs. GPU telemetry is collected by the DCGM Exporter and forwarded to VictoriaMetrics. Since all log data is stored on internal servers, the domestic data storage obligation is naturally satisfied.

In particular, to meet the access history retention requirements of NIS security monitoring guidelines, a Python Admin API server (FastAPI) serves as a dedicated audit log collector. This component -- explicitly specified in the control plane logical architecture documentation -- stores the subject, timestamp, target resource, and result of each API request in PostgreSQL and also streams to VictoriaLogs. Audit logs are configured for a minimum retention period of six months, adjustable to institutional policy.

Another key strength of the observability stack is GPU resource visibility. The DCGM Exporter collects GPU temperature, memory usage, and compute utilization in real time, displaying them on the VictoriaMetrics dashboard. This allows operations teams to detect GPU node overload early and take proactive action such as workload redistribution or cooling measures.

### Satisfying the Domestic Data Storage Mandate

Because all platform components run on servers within the institution, no data -- including the content of LLM queries -- is transmitted externally. Model weight files are also stored and managed in internal storage (Longhorn or NFS).

---

## Implications for ThakiCloud AI Platform Adoption

### Full Air-Gap Support

ThakiCloud AI Platform was designed from the ground up to support on-premises and air-gapped environments. A logical architecture document exists for the KSA (Kingdom of Saudi Arabia) sovereign cloud deployment, and there is a reference for operating the entire platform on a purely on-premises stack including bare-metal servers, GPU nodes, and InfiniBand fabric. This goes beyond simply "supporting on-premises installation" -- it represents a complete full-stack configuration capable of independent operation with no public cloud dependencies.

### Six Fine-Tuning Pipelines

Public sector organizations often need models fine-tuned on institution-specific documents and regulatory data rather than general-purpose LLMs. ThakiCloud AI Platform supports six fine-tuning methods -- SFT, DPO, GRPO, CPT, GKD, and LoRA -- via Kubeflow TrainJob. Offering a wider range of fine-tuning options within a single platform is a key differentiator compared to competing solutions.

### GPU Resource Efficiency via Kueue and KAI Scheduler

Public sector organizations cannot simply purchase additional GPUs on demand the way public cloud users can. Fair sharing of limited GPU resources across multiple departments is critical. Kueue and the KAI custom scheduler support fair-share queuing and Gang Scheduling, reclaiming idle GPU resources to improve utilization (30-50% reclaim [estimate] per pitch deck). Logical partitioning of a single GPU using MIG (Multi-Instance GPU) enables even finer-grained allocation of smaller inference requests.

### Technical Foundation for NIS Security Compliance

Keycloak OIDC MFA, four-tier RBAC, ArgoCD-based change history, VictoriaLogs audit logs, and PostgreSQL-based audit event storage provide the technical foundation for the core requirements of NIS security monitoring guidelines. That said, obtaining CSAP certification requires not only technical configuration but also non-technical elements such as operational procedures, staffing, and physical security -- so certification is not automatically achieved by adopting the platform alone. The platform serves as a starting point that satisfies the technical control items.

### Multi-Cluster Centralized Management

For large ministries or those with multiple subsidiary agencies, NATS and gRPC-based multi-cluster centralized management allows distributed GPU clusters to be operated from a single console. ArgoCD Manager handles integrated GitOps synchronization status across clusters, making it easy to maintain consistent configuration when operating multiple sites.

---

## Limitations and Adoption Considerations

### Initial Build Costs and Specialist Personnel

Unlike public cloud SaaS, on-premises air-gap deployment requires upfront server procurement, network configuration, and internal staff or partners with Kubernetes operational expertise. In particular, image mirroring in air-gapped environments, issuing TLS certificates from an internal CA via cert-manager, and internal DNS design are tasks that require experienced engineers.

### Model Updates and Security Patch Management

In an air-gapped environment, new LLM model versions or platform security patches cannot be automatically downloaded from external sources. Periodic image mirroring procedures and change validation processes must be established in advance, creating an ongoing operational burden.

### Resolving On-Premises DNS/SSL Constraints Up Front

As noted above, on-premises environments often cannot support wildcard DNS and SSL. Before platform adoption, a decision must be made on either a fixed subdomain pool per service or a port-based access policy. Delaying this decision makes post-deployment URL restructuring difficult.

### CSAP Certification Requires a Separate Initiative

While ThakiCloud AI Platform provides a foundation that satisfies technical control items, CSAP certification itself is a comprehensive evaluation process that includes non-technical elements such as operational procedures, physical security, and personnel security. If certification is the goal, work with your institution's information security team or a specialized consulting partner to develop a separate certification plan.

### Phased Adoption Recommended

Rather than deploying the full platform at once, a more practical approach is to start with inference endpoint services and progressively expand to fine-tuning and ML pipelines. We recommend building operational experience with a small pilot cluster initially, then expanding to a multi-cluster configuration.

---

The constraints of network separation and air-gapped environments may feel like barriers to AI adoption. However, these constraints actually provide a clear boundary from a data sovereignty and security perspective, and can serve as an opportunity to systematically manage and leverage internal GPU infrastructure. ThakiCloud AI Platform is a full-stack solution designed for precisely this environment, providing the technical foundation for public sector organizations to operate sovereign AI securely and efficiently.

If you are considering adoption, please contact the ThakiCloud technical team for detailed architecture design tailored to your institution's environment.
