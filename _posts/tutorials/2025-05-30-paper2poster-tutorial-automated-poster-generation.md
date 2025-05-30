---
title: "Paper2Poster 튜토리얼: 학술 논문을 자동으로 포스터로 변환하는 멀티모달 AI 시스템"
date: 2025-05-30
categories: 
  - tutorials
tags: 
  - Paper2Poster
  - Academic Poster
  - Multimodal AI
  - Scientific Communication
  - Automation
  - PosterAgent
author_profile: true
toc: true
toc_label: "목차"
---

학술 포스터 제작은 연구자들에게 중요하지만 시간이 많이 소요되는 작업입니다. 긴 논문을 시각적으로 일관성 있는 한 페이지로 압축하는 것은 쉽지 않은 일이죠. **Paper2Poster**는 이러한 문제를 해결하기 위해 개발된 최초의 자동화된 포스터 생성 시스템입니다.

## Paper2Poster 개요

![Paper2Poster Overview](/assets/images/posts/tutorial/paper2poster-overall.png)

*Paper2Poster 시스템 개요: 논문 PDF에서 완성된 포스터까지의 전체 프로세스*

Paper2Poster는 두 가지 핵심 질문에 답합니다:
- **How to create poster?** → **PosterAgent**로 해결
- **How to evaluate poster?** → **Paper2Poster 벤치마크**로 해결

### 주요 특징

- **완전 자동화**: 22페이지 논문을 편집 가능한 `.pptx` 포스터로 변환
- **비용 효율성**: 단 **$0.005**로 포스터 생성 가능
- **높은 성능**: GPT-4o 대비 87% 적은 토큰으로 더 나은 성능
- **오픈소스**: 코드와 데이터셋 모두 공개

## PosterAgent 아키텍처

![PosterAgent Architecture](/assets/images/posts/tutorial/paperagent.png)
*PosterAgent의 3단계 파이프라인: Parser → Planner → Painter-Commenter*

PosterAgent는 **top-down, visual-in-the-loop** 멀티에이전트 시스템으로 구성됩니다:

### 1. Parser (파서)
- **기능**: 논문을 구조화된 자산 라이브러리로 변환
- **출력**: Key-Value 형태의 구조화된 콘텐츠
- **처리**: 텍스트, 이미지, 표, 그래프 등 모든 요소 추출

### 2. Planner (플래너)
- **기능**: 텍스트-비주얼 쌍을 이진 트리 레이아웃으로 정렬
- **특징**: 읽기 순서와 공간적 균형 보존
- **출력**: 체계적인 패널 구조

### 3. Painter-Commenter (페인터-코멘터)
- **기능**: 각 패널을 반복적으로 개선
- **프로세스**: 
  - 렌더링 코드 실행
  - VLM 피드백으로 오버플로우 제거
  - 정렬 및 시각적 품질 보장

## 설치 및 설정

### 필수 요구사항

```bash
# 의존성 설치
pip install -r requirements.txt

# LibreOffice 설치 (Linux)
sudo apt install libreoffice
```

### API 키 설정

프로젝트 루트에 `.env` 파일을 생성하고 OpenAI API 키를 추가합니다:

```bash
OPENAI_API_KEY=<your_openai_api_key>
```

### 데이터 구조

논문 파일을 다음과 같이 구성합니다:

```
📁 {dataset_dir}/
└── 📁 {paper_name}/
    └── 📄 paper.pdf
```

## 빠른 시작 가이드

### GPT-4o 사용 (기본)

```bash
python -m PosterAgent.new_pipeline \
    --poster_path="${dataset_dir}/${paper_name}/paper.pdf" \
    --model_name_t="4o" \
    --model_name_v="4o" \
    --poster_width_inches=48 \
    --poster_height_inches=36
```

### Qwen-2.5 + GPT-4o 조합 (권장)

```bash
python -m PosterAgent.new_pipeline \
    --poster_path="${dataset_dir}/${paper_name}/paper.pdf" \
    --model_name_t="vllm_qwen" \
    --model_name_v="4o" \
    --poster_width_inches=48 \
    --poster_height_inches=36
```

### 완전 로컬 환경 (Qwen-2.5)

```bash
python -m PosterAgent.new_pipeline \
    --poster_path="${dataset_dir}/${paper_name}/paper.pdf" \
    --model_name_t="vllm_qwen" \
    --model_name_v="vllm_qwen_vl" \
    --poster_width_inches=48 \
    --poster_height_inches=36
```

### 최고 성능 (o3 모델)

```bash
python -m PosterAgent.new_pipeline \
    --poster_path="${dataset_dir}/${paper_name}/paper.pdf" \
    --model_name_t="o3" \
    --model_name_v="o3" \
    --poster_width_inches=48 \
    --poster_height_inches=36
```

## 평가 시스템

Paper2Poster는 포스터 품질을 다각도로 평가하는 종합적인 메트릭을 제공합니다:

### 평가 데이터셋 다운로드

```bash
python -m PosterAgent.create_dataset
```

### 1. PaperQuiz 평가

포스터가 논문의 핵심 내용을 얼마나 잘 전달하는지 측정:

```bash
python -m Paper2Poster-eval.eval_poster_pipeline \
    --paper_name="${paper_name}" \
    --poster_method="${model_t}_${model_v}_generated_posters" \
    --metric=qa
```

### 2. VLM-as-Judge 평가

6가지 세부 미적/정보적 기준으로 평가:

```bash
python -m Paper2Poster-eval.eval_poster_pipeline \
    --paper_name="${paper_name}" \
    --poster_method="${model_t}_${model_v}_generated_posters" \
    --metric=judge
```

### 3. 통계적 메트릭 평가

시각적 유사성, PPL 등 정량적 지표:

```bash
python -m Paper2Poster-eval.eval_poster_pipeline \
    --paper_name="${paper_name}" \
    --poster_method="${model_t}_${model_v}_generated_posters" \
    --metric=stats
```

### 커스텀 PaperQuiz 생성

자신의 논문에 대한 퀴즈를 생성하려면:

```bash
python -m Paper2Poster-eval.create_paper_questions \
    --paper_folder="Paper2Poster-data/${paper_name}"
```

## 평가 메트릭 상세

### 1. Visual Quality
- **목적**: 인간이 제작한 포스터와의 의미적 정렬도 측정
- **방법**: 시각적 요소의 배치와 디자인 품질 평가

### 2. Textual Coherence  
- **목적**: 언어의 유창성과 일관성 측정
- **방법**: 텍스트 품질과 가독성 분석

### 3. Holistic Assessment
- **목적**: 6가지 세부 미적/정보적 기준으로 종합 평가
- **방법**: VLM-as-judge를 통한 다면적 품질 평가

### 4. PaperQuiz
- **목적**: 포스터의 핵심 내용 전달 능력 측정
- **방법**: VLM이 생성된 퀴즈에 답하는 능력으로 평가

## 성능 및 비용 분석

### 주요 성과
- **토큰 효율성**: GPT-4o 대비 87% 적은 토큰 사용
- **비용 효율성**: 포스터 하나당 $0.005
- **품질**: 거의 모든 메트릭에서 기존 4o 기반 시스템 능가

### 발견된 인사이트
- **GPT-4o의 한계**: 시각적으로 매력적이지만 텍스트 노이즈와 낮은 PaperQuiz 점수
- **핵심 병목**: 독자 참여도가 주요 미적 병목점
- **인간 디자인의 특징**: 시각적 의미론에 크게 의존하여 의미 전달

## 활용 팁

### 1. 모델 조합 최적화
- **비용 중시**: Qwen-2.5 + GPT-4o 조합 권장
- **품질 중시**: o3 모델 사용
- **완전 로컬**: vLLM 기반 Qwen 모델 활용

### 2. 포스터 크기 조정
- **학회 표준**: 48×36 인치 권장
- **온라인 발표**: 더 작은 크기로 조정 가능

### 3. 커스터마이징
- `utils/wei_utils.py`의 `get_agent_config()` 함수에서 설정 변경
- LLM/VLM 조합을 자유롭게 실험

## 마무리

Paper2Poster는 학술 커뮤니케이션의 효율성을 크게 향상시킬 수 있는 혁신적인 도구입니다. 완전 자동화된 포스터 생성을 통해 연구자들이 콘텐츠 제작에 더 집중할 수 있게 해주며, 오픈소스로 제공되어 누구나 활용할 수 있습니다.

다음 세대의 완전 자동화된 포스터 생성 모델을 위한 명확한 방향을 제시하는 이 연구는, 학술 발표 준비 시간을 대폭 단축시키고 더 나은 시각적 커뮤니케이션을 가능하게 할 것입니다.

### 참고 자료

- [GitHub 리포지토리](https://github.com/Paper2Poster/Paper2Poster)
- [데이터셋 및 코드](https://github.com/Paper2Poster/Paper2Poster) 