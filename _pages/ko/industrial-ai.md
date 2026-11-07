---
title: "산업 AI 모델"
seo_title: "산업 AI 모델 허브 - 모터 전류·설비 센서·균열 비전·설비 명령 연구 모델 | ThakiCloud"
seo_description: "ThakiCloud가 Hugging Face에 공개한 산업 AI 연구 모델을 한곳에 모았습니다. 모터 전류 고장 분류, 설비 센서 상태 진단, 콘크리트 균열 탐지, 설비 명령 제안 모델의 평가 조건과 한계, 현장 도입 전에 확인할 것을 정리합니다."
layout: posts
permalink: /ko/industrial-ai/
lang: ko
default_tag: industrial-ai
author_profile: true
sitemap: true
published: true
---

ThakiCloud가 Hugging Face에 공개한 산업 AI 모델을 한곳에 모았습니다. 모두 연구 미리보기(research preview)이며 제품 출시가 아닙니다. 모델마다 데이터, 평가 방식, 라벨의 성격이 다르므로 아래 숫자를 모델 사이의 순위로 읽으면 안 됩니다.

## 쉽게 말하면

이 모델들은 공장 점검반의 신입 점검원과 비슷합니다. 교육장에서는 시험을 잘 봤지만 아직 실제 현장에 혼자 나간 적은 없습니다. 그래서 각 모델이 어떤 교육장에서 어떤 시험을 봤는지, 무엇은 아직 시험하지 않았는지를 함께 적었습니다.

## 한눈에 보기

| 모델 | 입력 | 하는 일 | 대표 지표와 평가 조건 | 라이선스 |
|---|---|---|---|---|
| Thaki-MCSA-MantisV2-MCC5 | 3상 모터 전류 | 고장 상태 24가지 분류 | 봉인 TEST 71개 녹화 Macro-F1 0.943, 단일 시험 장치 | Apache-2.0 |
| Thaki-EquipmentHealth-Sensor-LGBM | 물류 차량 전류·온도·미세먼지 센서 | 설비 상태 네 단계 분류 | 처음 보는 차량 매크로 F1 0.94, 라벨은 테스트베드 모의 시스템 값 | CC BY 4.0 |
| Thaki-FacilityVision-CrackCls-ResNet18 · CrackSeg-E2 | 콘크리트 표면 사진 | 균열 조각 분류 · 픽셀 분할 | 분류 Macro F1 0.9993, 분할 Dice 0.8983, 공개 데이터 한 곳 | CC BY 4.0 |
| Thaki-FactoryShield-KO-7M | 한국어 설비 명령 문장 | 실행하지 않는 명령 제안 또는 거절 | 합성 봉인 테스트만 통과, 실제 현장 발화 미평가 | 자체 연구 라이선스 |

## 모델 카드

### Thaki-MCSA-MantisV2-MCC5

- **용도**: 모터의 3상 전류만으로 정상과 고장 23가지를 구분하는 연구 모델입니다. 시계열 사전학습 모델 MantisV2를 미세조정했습니다.
- **입력과 추론**: 12.8kHz 전류를 65,536샘플 창으로 자르고 상별 Welch 로그 스펙트럼 512칸을 만든 뒤 창별 확률을 평균해 녹화 하나를 판정합니다.
- **대표 지표**: 학습에 쓰지 않은 운전 조건 3개의 봉인 TEST 71개 녹화에서 Macro-F1 0.943입니다. 개발 단계 LOCO 교차검증 0.945는 fold마다 다시 학습한 모델의 평균이고 공개 파일은 개발용 녹화 208개 전체로 다시 학습한 모델 하나입니다.
- **한계**: 같은 TEST에서 녹화 시각만 쓰는 기준선이 0.986, 날짜만 쓰는 기준선은 0.127이었습니다. 시험 장치가 한 대뿐이라 다른 물리 모터로 일반화된다고 주장하지 않습니다. 틀린 4건 중 3건은 권선 고장 H와 L의 혼동입니다.
- **데이터**: MCC5-THU, Mendeley Data, CC BY 4.0.
- **링크**: [Hugging Face](https://huggingface.co/ThakiCloud/Thaki-MCSA-MantisV2-MCC5) · 관련 글 [MCSA 모델 공개](/tech-blog/ko/research/thaki-mcsa-mantisv2-mcc5/)

### Thaki-EquipmentHealth-Sensor-LGBM

- **용도**: 반도체 공장 물류 차량(OHT·AGV)의 센서 값으로 상태를 정상·관심·경고·위험 네 단계로 나눕니다. 모델 크기는 약 1MB입니다.
- **대표 지표**: 처음 보는 차량에서 매크로 F1 0.94였고 위험 930건을 정상으로 판정한 경우는 0건이었습니다.
- **한계**: 라벨은 실제 고장 기록이 아니라 데이터셋의 테스트베드 모의 시스템이 붙인 값입니다. 실제 고장을 미리 맞힌다고 주장하지 않습니다. 정상 20건 중 1건꼴로 관심 경보가 울립니다.
- **데이터**: AI 허브(AI-Hub) 데이터셋 71802(OHT·AGV 설비). 데이터는 재배포하지 않습니다.
- **링크**: [Hugging Face](https://huggingface.co/ThakiCloud/Thaki-EquipmentHealth-Sensor-LGBM) · 관련 글 [설비 센서 상태 진단](/tech-blog/ko/research/thaki-equipmenthealth-sensor-paxis-maintenance/)

### Thaki-FacilityVision-CrackCls-ResNet18 · CrackSeg-E2

- **용도**: 점검 사진에서 균열 조각을 고르는 분류 모델(ResNet-18, 약 1,100만 파라미터)과 균열 모양을 원래 해상도로 그리는 분할 모델(ResNet-34 인코더 U-Net, 약 2,400만 파라미터)입니다.
- **대표 지표**: 분류 모델은 시험 조각 5,524장에서 Macro F1 0.9993이었습니다. 분할 모델은 개발셋 60장에서 Dice 0.8983, 얇은 균열 재현율 0.9139였습니다.
- **한계**: 공개 데이터 한 곳에서만 잰 값이라 현장 정확도로 읽으면 안 됩니다. 분할 모델의 시험셋 61장은 아직 채점하지 않았습니다.
- **데이터**: Ç. F. Özgenel, Mendeley Data, CC BY 4.0.
- **링크**: [CrackCls](https://huggingface.co/ThakiCloud/Thaki-FacilityVision-CrackCls-ResNet18) · [CrackSeg](https://huggingface.co/ThakiCloud/Thaki-FacilityVision-CrackSeg-E2) · 관련 글 [균열 비전 모델](/tech-blog/ko/research/thaki-facilityvision-crack-paxis-inspection/)

### Thaki-FactoryShield-KO-7M

- **용도**: 한국어 설비 명령을 동작·설비 ID·지연 시간으로 된 제안으로 바꾸거나 거절합니다. 파라미터는 7,352,909개이며 출력의 `safe_to_actuate`는 항상 `false`입니다.
- **안전 경계**: 모델이 고른 설비 ID를 등록 설비 목록과 정확히 대조하고 목록에 없거나 목록이 없으면 `ABSTAIN`을 냅니다.
- **대표 지표**: 합성 봉인 테스트에서 모델 단독 위험률은 2.57~3.90%, 검증기와 등록 목록을 합친 시스템 위험률은 0.00~0.33%였습니다.
- **한계**: 모든 수치가 합성 데이터에서 나왔고 실제 설비 환경에서 안전성을 검증한 적은 없습니다.
- **링크**: [Hugging Face](https://huggingface.co/ThakiCloud/Thaki-FactoryShield-KO-7M) · 관련 글 [FactoryShield 공개](/tech-blog/ko/agentops/thaki-factoryshield-ko-7m-paxis/)

## 공개 모델이 증명하는 것과 아닌 것

세 가지를 구분해서 읽으시기 바랍니다.

**연구 모델로 확인한 것**은 위 카드에 적은 데이터와 평가 조건 안의 결과입니다. 가중치와 평가 계약을 공개해 누구나 같은 조건에서 다시 잴 수 있습니다.

**플랫폼이 제공하는 것**은 모델을 고객 환경에서 학습하고 서빙하는 운영 계층(Metis)과, 모델 판정을 담당자 검토·승인·업무 기록으로 잇는 에이전트 계층(Paxis)입니다. 각 글의 Paxis 흐름은 참조 설계이며 이 모델들을 통합 제품으로 현장에서 실측한 결과가 아닙니다.

**현장 PoC로 확인해야 하는 것**은 다른 장비에서도 통하는지, 실제 고장 기록 기준의 성능, 운전 시간당 오경보와 고장 누락, 현장 장치의 지연 시간입니다. 이 항목은 공개 데이터로 답할 수 없고 고객 설비 데이터와 평가 설계가 있어야 잴 수 있습니다.

## 도입을 검토한다면

1. **설비와 데이터를 먼저 봅니다.** 장비 종류, 센서 구성, 샘플링 주파수, 정상·고장 기록이 어떤 조건에서 쌓였는지가 모델 선택보다 먼저입니다.
2. **평가 설계를 정합니다.** 학습에 쓰지 않은 장비나 기간을 따로 떼어 두고 장비 ID나 수집 시각이 정답을 대신하지 않는지 확인합니다.
3. **문의를 남깁니다.** 자사 설비 데이터로 검토하고 싶다면 [ThakiCloud에 문의](/contact?interest=industrial-ai&origin=industrial-ai-hub)하시기 바랍니다.

## 관련 글

아래 목록은 `industrial-ai` 태그가 붙은 글 전체입니다. 주요 글은 다음과 같습니다.

- [모터 전류 분석(MCSA) AI 모델을 공개했습니다](/tech-blog/ko/research/thaki-mcsa-mantisv2-mcc5/)
- [센서 값으로 설비 상태를 읽고, Paxis가 정비 업무를 엽니다](/tech-blog/ko/research/thaki-equipmenthealth-sensor-paxis-maintenance/)
- [콘크리트 균열을 찾는 작은 비전 모델 두 개를 공개했습니다](/tech-blog/ko/research/thaki-facilityvision-crack-paxis-inspection/)
- [설비 명령을 실행하지 않고 제안만 하는 7M 모델, Thaki-FactoryShield-KO-7M](/tech-blog/ko/agentops/thaki-factoryshield-ko-7m-paxis/)
