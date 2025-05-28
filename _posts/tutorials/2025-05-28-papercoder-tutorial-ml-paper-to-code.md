---
title: "PaperCoder 튜토리얼: 머신러닝 논문을 즉시 실행 코드 리포지토리로 변환하기"
date: 2025-05-28
categories: 
  - tutorials
tags: 
  - Machine Learning
  - Code Generation
  - LLM
  - Automation
  - Research Tools
author_profile: true
toc: true
toc_label: "목차"
---

머신러닝 논문은 매주 쏟아지지만, 실제 구현 코드가 공개되지 않아 **재현‧확장**이 어려운 경우가 많습니다.
**PaperCoder**는 이러한 문제를 해결하기 위해 제안된 **멀티-에이전트 LLM 시스템**으로, 논문 하나만 있으면 완전한 코드 리포지토리를 자동 생성합니다.

## PaperCoder 한눈에 보기

| 핵심 요소     | 설명                                                                                      |
| --------- | --------------------------------------------------------------------------------------- |
| **파이프라인** | **Planning → Analysis → Code Generation**의 3-단계. 단계마다 특화된 LLM 에이전트가 협업합니다. |
| **평가**    | Paper2Code·PaperBench 두 벤치마크에서 기존 강력한 베이스라인을 크게 앞섰습니다.                     |
| **출시**    | arXiv 2025-04-24, v3 기준 2025-05-18 업데이트.                                   |
| **코드**    | GitHub → `going-doer/Paper2Code`.                                         |

> **TL;DR** : "논문 PDF ➜ `bash run.sh` ➜ 실행 가능한 모듈형 코드 리포지토리"

## 빠른 시작

### OpenAI API 사용

```bash
# 라이브러리 설치
pip install openai

# API 키 설정
export OPENAI_API_KEY="<YOUR_OPENAI_API_KEY>"

# 예시 논문(Attention-Is-All-You-Need) 실행
cd scripts
bash run.sh
```

- **비용** (o3-mini 기준): 약 **$0.50 – $0.70** per paper

### 오픈소스 LLM(vLLM) 사용

```bash
pip install vllm

cd scripts
bash run_llm.sh   # 기본 모델: deepseek-ai/DeepSeek-Coder-V2-Lite-Instruct
```

## 폴더 구조 이해

```bash
outputs/
└── Transformer/
    ├── planning_artifacts/   # 단계 1 결과
    ├── analyzing_artifacts/  # 단계 2 결과
    └── coding_artifacts/     # 단계 3 결과
└── Transformer_repo/         # 최종 코드 리포지토리
```

각 아티팩트에는 명령 흐름, 파일 종속성 그래프, 코드 스텁 등이 포함되어 있어 **디버깅·학습 용도**로 바로 활용할 수 있습니다.

## PDF → JSON 변환 (선택사항)

LaTeX 소스가 없을 때는 논문 PDF를 JSON으로 변환해 구조적 정보를 강화할 수 있습니다.

```bash
git clone https://github.com/allenai/s2orc-doc2json.git
cd s2orc-doc2json/grobid-0.7.3
./gradlew run          # Grobid 서버 실행

# 실제 변환
mkdir -p ./output_dir/paper_coder
python doc2json/grobid2json/process_pdf.py \
  -i <PDF_PATH> \
  -t ./temp_dir/ \
  -o ./output_dir/paper_coder
```

변환 후 `run.sh`의 `PDF_JSON_PATH` 환경변수만 바꿔주면 됩니다.

## 결과 평가하기

PaperCoder는 자체 스크립트로 **모델 기반 평가**를 지원합니다.

### Reference-free 평가

```bash
cd codes
python eval.py \
  --paper_name Transformer \
  --pdf_json_path ../examples/Transformer_cleaned.json \
  --target_repo_dir ../outputs/Transformer_repo \
  --eval_type ref_free \
  --generated_n 8 \
  --papercoder
```

### Reference-based 평가

공식 구현 코드가 있을 때 권장됩니다.

```bash
cd codes
python eval.py \
  --paper_name Transformer \
  --pdf_json_path ../examples/Transformer_cleaned.json \
  --target_repo_dir ../outputs/Transformer_repo \
  --gold_repo_dir ../examples/Transformer_gold_repo \
  --eval_type ref_based \
  --generated_n 8 \
  --papercoder
```

샘플 리포지토리 기준 **4.5 / 5.0** 점수를 확인할 수 있습니다.

## 활용 팁

1. **모델 교체**: vLLM으로 원하는 코드 특화 모델(e.g., CodeLlama)도 쉽게 바꿀 수 있습니다.
2. **커스텀 에이전트**: `scripts/planning_agent.py` 등 에이전트 스크립트를 수정해 파이프라인을 확장해 보세요.
3. **클라우드 비용 최적화**: `--generated_n` 값을 줄이면 토큰 사용량이 급감합니다.
4. **CI/CD 연동**: GitHub Actions로 변환 프로세스를 자동화하면 새 논문 업로드 시 즉시 코드가 생성됩니다.

## 마무리

PaperCoder는 "읽기 → 이해 → 구현"의 반복 루프를 **자동화**해 연구 생산성을 비약적으로 끌어올립니다.
*LLM-Ops*나 *Research Engineering* 파이프라인에 바로 도입해 보세요.

> "논문만 있으면 끝!"—실험, 재현, 확장까지 한 번에.

### 참고 자료

- [PaperCoder 논문 (arXiv)](https://arxiv.org/abs/2504.17192)
- [GitHub 리포지토리](https://github.com/going-doer/Paper2Code) 