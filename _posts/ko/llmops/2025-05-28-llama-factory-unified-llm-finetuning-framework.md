---
title: "LLaMA Factory: 100+ 모델을 손쉽게 파인튜닝하는 통합 LLM 프레임워크"
excerpt: "Llama 3, Qwen 3, DeepSeek 등 100+ 최신 LLM을 코드 한 줄로 파인튜닝. LoRA/QLoRA, FSDP, Flash-Attention 2 등 최신 기법 통합한 오픈소스 프레임워크"
date: 2025-05-28
categories:
  - llmops
tags:
  - LLaMAFactory
  - LoRA
  - QLoRA
  - LLM
  - 파인튜닝
  - MLOps
  - AI프레임워크
  - 오픈소스
author_profile: true
toc: true
toc_label: "LLaMA Factory 가이드"
---

> **TL;DR** LLaMA Factory는 Llama 3, Qwen 3, DeepSeek, Mistral 등 100종 이상의 최신 대형 언어·멀티모달 모델을 **코드 한 줄**로 학습·배포할 수 있는 오픈소스 프레임워크다. LoRA/QLoRA, FSDP, Flash‑Attention 2, vLLM, PPO/DPO/KTO/ORPO 등 최신 기법을 통합하고, CLI·Gradio 기반 Web UI를 제공해 연구·프로덕션 경계를 크게 좁혀준다.

---

## 1. LLaMA Factory란?

LLaMA Factory는 **PyTorch** 기반의 오픈소스 LLM 파인튜닝 프레임워크다. 다음과 같은 특징을 제공한다.

- **100+ 모델** 지원 — Llama 3/4, Qwen 3, DeepSeek, Yi, Gemma 3, Mixtral‑MoE, LLaVA‑NeXT 등.
- **다양한 학습 접근법** — Full/Freeze/LoRA/QLoRA, (멀티모달) SFT, Reward Model, PPO, DPO, KTO, ORPO, SimPO 등.
- **효율 최적화** — FlashAttention‑2, Unsloth, GaLore, BAdam, APOLLO, DoRA, LongLoRA, Mixture‑of‑Depths, PiSSA.
- **간편한 사용성** — `llamafactory-cli train …` 한 줄, 또는 Gradio 기반 **LLaMA Board** GUI.
- **배포 친화적** — OpenAI‑style REST API(`/v1/chat/completions`), vLLM·SGLang 백엔드, Docker & K8s 예제.

> Amazon SageMaker HyperPod, NVIDIA RTX AI Toolkit, Aliyun PAI‑DSW 등에서 이미 활용되고 있다.

## 2. 왜 써야 할까?

### 2‑1. 연구와 서비스의 간극 해소

세부 파이프라인(데이터 전처리 → 학습 → 평가 → 추론 → 배포)을 한 프레임워크에서 처리해 **MLOps 복잡도**를 크게 낮춘다.

### 2‑2. 유연한 자원 활용

LoRA·QLoRA·FSDP 조합으로 **70B 모델**도 2×24GB GPU에서 학습 가능. Ascend NPU·AMD ROCm도 지원.

### 2‑3. 최신 알고리즘 Day‑N 지원

논문 공개 D+1일 내 주요 모델·알고리즘을 통합(예: Llama 4, GLM‑4, Muon, GaLore).

## 3. 주요 기능 한눈에 보기

- **CLI**: `train/chat/export/api` 4개의 명령으로 전체 워크플로우 제공.
- **Web UI (LLaMA Board)**: 데이터셋 업로드부터 하이퍼파라미터 설정, 실시간 로그까지 시각화.
- **Docker 스택**: CUDA·NPU·ROCm별 Compose 파일 제공→로컬·클라우드 어디서나 동일 환경.
- **대규모 데이터셋 번들**: 80+ 공개 SFT/RLHF/멀티모달 데이터셋 사전 정의.
- **Experiment Tracker**: TensorBoard, W&B, SwanLab, MLflow.

## 4. 지원 모델 빠른 스냅샷

| 계열            | 예시                               | 파라미터 크기     |
| ------------- | -------------------------------- | ----------- |
| **Meta**      | Llama 2·3·4                      | 7B → 402B   |
| **Alibaba**   | Qwen 1‑3 / Qwen 2‑VL             | 0.5B → 235B |
| **Mistral**   | Mistral / Mixtral‑MoE            | 7B → 8×22B  |
| **Google**    | Gemma 3 / PaliGemma 2            | 1B → 28B    |
| **OpenGVLab** | InternVL 3‑8B                    | 8B          |
| …             | DeepSeek, Yi, Phi 4, MiniCPM‑V 등 |             |

> 전체 목록과 템플릿 매핑은 `constants.py`에서 확인 가능.

## 5. 3분 Quick Start

```bash
# 1) LoRA‑SFT 예시 (Llama 3‑8B‑Instruct)
llamafactory-cli train examples/train_lora/llama3_lora_sft.yaml

# 2) 대화형 추론
llamafactory-cli chat examples/inference/llama3_lora_sft.yaml

# 3) LoRA 어댑터 병합 & 체크포인트 내보내기
llamafactory-cli export examples/merge_lora/llama3_lora_sft.yaml
```

### Gradio GUI 실행

```bash
llamafactory-cli webui  # localhost:7860 접속
```

### Docker Compose (CUDA)

```bash
cd docker/docker-cuda && docker compose up -d
```

## 6. 실전 Tips

1. **FlashAttention‑2**: `flash_attn: fa2` 설정으로 A100 기준 30% 이상 속도 향상.
2. **QLoRA**: 4‑bit 양자화 + LoRA면 8B 모델을 6GB vRAM으로 fine‑tune.
3. **NEFTune**: `neftune_noise_alpha: 5`로 정규화→수렴 속도 개선.
4. **vLLM 서빙**: `infer_backend: vllm`으로 평균 2.7× TPS 증가.

## 7. 참고 링크

- **GitHub**: [https://github.com/hiyouga/LLaMA-Factory](https://github.com/hiyouga/LLaMA-Factory)
- **문서**: [https://llamafactory.readthedocs.io/en/latest/](https://llamafactory.readthedocs.io/en/latest/)
- **Colab 노트북**: [https://colab.research.google.com/drive/1eRTPn37ltBbYsISy9Aw2NuI2Aq5CQrD9](https://colab.research.google.com/drive/1eRTPn37ltBbYsISy9Aw2NuI2Aq5CQrD9)
- **지원 Discord**: [https://discord.gg/rKfvV9r9FK](https://discord.gg/rKfvV9r9FK)

프레임워크·모델 라이선스는 Apache‑2.0 및 각 모델 고유 라이선스를 준수해야 한다. 세부 내용은 저장소 `LICENSE` 파일과 모델 카드 참고.

---
