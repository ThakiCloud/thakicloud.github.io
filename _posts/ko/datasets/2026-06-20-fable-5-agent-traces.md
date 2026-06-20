---
title: "Fable-5-traces: 코딩 에이전트 세션 trace로 소형 모델을 蒸溜하는 방법"
excerpt: "Glint-Research가 공개한 Fable 5(Claude Code) 에이전트 trace 4,665개. AGPL-3.0, HF Agent Traces 포맷, tool-use 81% 구성. 소형 모델 distillation과 자가호스팅 코드 에이전트 구축에 활용하는 실전 가이드."
date: 2026-06-20
categories:
  - datasets
tags:
  - agent-traces
  - fable-5
  - claude-code
  - distillation
  - sft
  - tool-use
  - chain-of-thought
  - coding-agent
  - agpl-3.0
author_profile: true
toc: true
toc_label: "Fable-5-traces 가이드"
reading_time: true
canonical_url: https://thakicloud.github.io/datasets/fable-5-agent-traces/
---

![Fable 5 에이전트 trace 개념도](/assets/images/fable-5-agent-traces-hero.png)

## 데이터셋 개요

**Fable-5-traces**는 Glint-Research가 공개한 코딩 에이전트 세션 trace 모음집입니다. Fable 5, 즉 Claude Code가 실제 코딩 작업을 수행하는 과정에서 발생한 추론, 도구 호출, 텍스트 출력을 그대로 담은 데이터셋으로, Hugging Face Agent Traces 포맷으로 변환해 공개했습니다.

에이전트가 "무엇을 생각하고, 어떤 도구를 왜 선택했으며, 결과를 어떻게 처리했는가"를 추적할 수 있는 원시 trace 데이터는 소형 언어 모델을 정책 모델로 훈련시킬 때 핵심 재료가 됩니다. 이 데이터셋은 바로 그 용도로 설계되었습니다.

## 구성과 스키마

### 규모

- 총 4,665개 병합 학습 예제(merged training examples)
- 원본 Pi-style trace 파일 4,665개
- 세션 출처 60개(unique source sessions)
- 전체 크기 188 MB

### 두 가지 데이터 뷰

데이터셋은 두 가지 표현 방식을 동시에 제공합니다.

**Pi-style trace 뷰** (`pi-traces/*.jsonl`): 세션 이벤트, 모델 변경, thinking-level 메타데이터, 사용자 컨텍스트, 어시스턴트 추론과 도구 출력을 담은 원시 trace 파일입니다. 에이전트가 실제로 어떤 순서로 사고했는지 재현하는 데 씁니다.

**병합 JSONL 뷰** (`fable5_cot_merged.jsonl`): 모든 trace를 플랫 레코드로 변환한 파일입니다. 주요 필드는 다음과 같습니다.

| 필드 | 설명 |
|------|------|
| `uid` | 고유 식별자 |
| `source_file` | 원본 Pi trace 파일명 |
| `context` | 작업 맥락(평균 약 6,600자) |
| `cot` | 에이전트 추론 체인(중앙값 약 2,365자) |
| `output_type` | `tool_use` 또는 `text` |
| `output` | 실제 도구 호출 또는 텍스트 출력 |
| `completion` | 전체 완성 내용(평균 약 3,700자) |
| `model` | 호출에 사용된 모델 정보 |
| `origin` | trace 출처 |

### 도구 분포

전체 4,665개 레코드 중 3,799개(81.44%)가 tool-use 레코드이고, 866개(18.56%)가 텍스트 출력 레코드입니다. 도구 종류는 Bash, Edit, Read, Write, PowerShell, WebSearch 등 실제 코딩 에이전트가 사용하는 범주로 구성되어 있습니다.

이 비율은 코딩 에이전트의 현실을 반영합니다. 언어 모델이 코딩 작업에서 생성하는 출력의 대부분은 텍스트가 아니라 도구 호출입니다.

### 태그

데이터셋 태그: `agent-traces`, `pi-agent`, `claude-code`, `fable-5`, `chain-of-thought`, `tool-use`

## 라이선스

AGPL-3.0입니다. 소스 코드 공개 의무가 있는 카피레프트 라이선스로, 이 데이터셋을 사용해 훈련한 모델을 서비스 형태로 배포할 경우 해당 서비스 코드 전체를 AGPL-3.0 조건에 따라 공개해야 합니다. 내부 연구용, 또는 자가호스팅 비공개 서비스 목적으로는 제약이 없습니다.

엔터프라이즈 환경에서 공개 서비스로 배포하려는 경우 라이선스 검토가 선행되어야 합니다. 연구 목적이거나 내부 도구를 만드는 ThakiCloud 운영 환경에서는 AGPL-3.0이 실질적 제약으로 작용하지 않습니다.

## 학습과 평가에서의 활용

### Distillation(지식 증류)

이 데이터셋의 핵심 용도는 대형 에이전트 모델의 행동을 소형 모델에 이식하는 것입니다. 절차는 다음과 같습니다.

먼저 `fable5_cot_merged.jsonl`에서 `context`와 `cot`, `output` 필드를 기반으로 SFT 데이터를 구성합니다. 에이전트가 특정 맥락에서 어떤 추론 과정을 거쳐 어떤 도구를 호출했는지를 (입력, 추론, 출력) 삼중쌍으로 변환합니다.

이 삼중쌍으로 Qwen 2.5 Coder 7B나 DeepSeek Coder 6.7B 같은 소형 코드 모델을 SFT하면 Fable 5 수준의 tool-use 행동을 부분적으로 재현할 수 있습니다.

### Tool-call 정책 모델링

tool-use 레코드 3,799개는 도구 선택 정책 모델을 훈련시키는 데도 적합합니다. 어떤 컨텍스트에서 Bash를 쓰는지, Read를 쓰는지, Edit과 Write 중 어느 것을 선택하는지의 패턴이 60개 세션에 걸쳐 분포되어 있습니다.

### Trace 시각화

Pi-style trace 뷰는 에이전트의 세션 재현에도 쓸 수 있습니다. 에이전트가 왜 특정 단계에서 막혔는지, 어떤 순서로 파일을 읽고 편집했는지를 사람이 리뷰하는 도구를 만들 수 있습니다.

## ThakiCloud 활용 각도

ThakiCloud의 K8s AI 플랫폼 맥락에서 이 데이터셋의 가장 직접적인 활용처는 두 가지입니다.

**온프레미스 코드 에이전트 훈련**: 국정원 보안 요구사항 등으로 외부 API 에이전트를 쓸 수 없는 환경에서 Qwen 계열 7B~14B 모델을 Fable-5-traces로 파인튜닝해 자가호스팅 코드 에이전트를 만들 수 있습니다. AGPL-3.0의 코드 공개 의무가 내부 서비스에는 적용되지 않기 때문에 라이선스 상 문제가 없습니다.

**AI 에이전트 도구 정책 검증**: 자체 개발한 에이전트가 어떤 도구를 어떤 순서로 사용하는지를 Fable 5 baseline과 비교할 수 있습니다. tool_use 레코드 3,799개의 도구 선택 분포를 기준점으로 삼아 내부 에이전트의 도구 활용 패턴을 정량화할 수 있습니다.

Kueue 기반 훈련 워크플로에 이 데이터셋을 직접 연결하면 Fable-5-traces SFT 실험을 K8s 배치 잡으로 관리할 수 있습니다. 데이터 188 MB는 단일 A10G GPU 노드에서도 충분히 처리 가능한 크기입니다.

## 정리

Fable-5-traces는 코딩 에이전트의 실제 행동을 담은 소규모이면서도 밀도 있는 데이터셋입니다. 4,665개 레코드는 절대적 규모로는 크지 않지만, 60개 세션에 걸쳐 추론부터 도구 호출까지 전 과정을 포함하는 고품질 trace 데이터입니다. AGPL-3.0 라이선스 조건만 확인한다면 소형 모델 distillation 실험의 출발점으로 쓸 수 있는 데이터셋입니다.

HuggingFace: [Glint-Research/Fable-5-traces](https://huggingface.co/datasets/Glint-Research/Fable-5-traces)
