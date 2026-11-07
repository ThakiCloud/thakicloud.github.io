---
title: "ThakiOCR 모델"
layout: posts
permalink: /ko/ocr/
lang: ko
default_tag: thakiocr
author_profile: true
sitemap: true
---

ThakiCloud가 공개한 문자 인식 모델 네 개를 한곳에 모았습니다. 네 모델 모두 연구용 공개이며 제품 출시가 아닙니다. 모델마다 입력 단위, 필요한 하드웨어, 평가 방식이 다르므로 아래 숫자는 모델 사이의 순위가 아닙니다.

## 쉽게 말하면

네 모델은 같은 공구함에 든 서로 다른 공구입니다. 작은 드라이버는 주머니에 넣고 다니며 하루에 수천 번 쓸 수 있고, 전동 드릴은 무겁지만 단단한 벽을 뚫습니다. 어느 공구가 더 좋으냐보다 지금 하려는 일에 어느 공구가 맞느냐가 중요합니다.

## 한눈에 보기

이 표는 규모와 쓰임새만 정리합니다. 성능 수치는 모델별 카드에 평가 계약과 함께 따로 적었습니다.

| 모델 | 규모 | 입력 단위 | 실행 환경 | 공개 상태 | 라이선스 |
|---|---|---|---|---|---|
| ThakiOCR-KOEN-V1-Dense | 213만 파라미터 | 텍스트 한 줄(한국어·영어) | CPU | 연구용 공개 | Apache-2.0 |
| ThakiOCR-KOEN-G2M-Preview | 893만 파라미터 | 텍스트 한 줄(한국어·영어) | CPU | 연구 프리뷰, A1_GEN2_NO_GO | Apache-2.0 |
| ThakiOCR-KO-v1 | 0.9B급 기반 모델 + LoRA 639만 파라미터 | 한국어 단어 이미지 한 장 | GPU | 연구 프리뷰 | Apache-2.0 |
| ThakiOCR-Large-27B-R2B | 27B 기반 모델 + LoRA 2억 3,350만 파라미터 | 한국어 단어 이미지 한 장 | GPU(bf16 약 53GB) | 연구 프리뷰 | Apache-2.0 |

KO-v1과 Large-27B-R2B는 LoRA 어댑터만 공개합니다. 기반 모델(ATH-MaaS/OvisOCR3, Qwen/Qwen3.6-27B)은 각 카드에 적힌 고정 리비전으로 따로 내려받아야 합니다.

## 모델 카드

아래 네 카드의 수치는 평가 세트와 지표가 서로 달라 모델 간 순위가 아닙니다. 각 수치 옆에 어떤 조건에서 쟀는지를 함께 적었습니다.

### ThakiOCR-KOEN-V1-Dense

- **규모**: 2,130,249 파라미터. 이 가운데 약 183만 개가 14,152자를 출력하는 마지막 층에 있습니다.
- **용도**: 잘라 낸 텍스트 한 줄을 읽는 CPU용 작은 기준선입니다. 줄 검출기나 레이아웃 모델 뒤에 붙여 씁니다.
- **대표 지표**: 실문서 한국어 개발 세트 CER 37.14%, 공백을 무시하면 17.81%입니다.
- **평가 계약**: AI 허브(AI-Hub)의 OCR 데이터(공공)(71299) 검증 데이터 일부의 단어 이미지 5,000개, 평가 전용입니다. 독립 시험 세트가 아닌 개발용 측정이며, 탐욕적 CTC 디코딩과 NFC 정규화 뒤 정확 일치로 채점했습니다. 학습 데이터와 같은 원천의 합성 한국어 세트에서는 CER 16.70%입니다.
- **속도**: 폭 512픽셀 줄 한 장 기준 데이터센터 서버 CPU 4스레드에서 중앙값 5.61ms입니다.
- **한계**: 실제 한국어 단어 이미지의 38%에서 음절 사이에 없는 공백을 넣습니다.
- **학습 데이터**: NVIDIA OCR-Synthetic-Multilingual-v1(CC BY 4.0)만 썼습니다. AI 허브 데이터는 학습에 쓰지 않았습니다.
- **라이선스**: 코드와 가중치 모두 Apache-2.0입니다.
- **링크**: [Hugging Face](https://huggingface.co/ThakiCloud/ThakiOCR-KOEN-V1-Dense) · 관련 글 [ThakiOCR A 공개](/tech-blog/ko/research/thakiocr-a-small-korean-english-line-ocr/)
- **공개 상태**: 연구용 공개(research release)입니다. 단일 시드 결과입니다.

### ThakiOCR-KOEN-G2M-Preview

- **규모**: 8,926,251 파라미터입니다. V1-Dense와 같은 계열의 줄 단위 CTC 인식기를 키우고 처음부터 다시 학습했습니다.
- **용도**: 원화 기호, 날짜, 원문자, 마스킹 숫자처럼 기호를 지켜야 하는 줄 인식 연구에 씁니다. CPU에서 한 줄 중앙값 13.3ms였습니다.
- **대표 지표**: 실문서 보류 세트의 텍스트 줄 CER 0.89%, 자체 생성 기호 시험 세트의 중요 토큰 엄격 일치율 94.2%입니다.
- **평가 계약**: 실문서 보류 세트는 AI 허브(AI-Hub)의 OCR 데이터(공공)(71299) Training 분할 가운데 학습에서 뺀 한 권의 줄 70개입니다. 기호 시험 세트는 학습과 문장이 겹치지 않게 새로 생성한 합성 줄 5,991개입니다. 두 세트 모두 학습 뒤 한 번만 열었고 미리 정한 기준은 바꾸지 않았습니다.
- **한계**: 미리 정해 둔 합격 기준(사전등록 게이트) 다섯 개 가운데 날짜 기준(I4)에서 떨어졌습니다. 실문서 날짜 토큰 4개 중 3개만 맞혔습니다.
- **라이선스**: Apache-2.0입니다. 학습 데이터는 세 가지입니다. NVIDIA OCR-Synthetic-Multilingual-v1(CC BY 4.0), SIL OFL 1.1 글꼴로 만든 자체 기호 합성 줄, AI 허브(AI-Hub)의 OCR 데이터(공공)(71299) Training 분할입니다.
- **링크**: [Hugging Face](https://huggingface.co/ThakiCloud/ThakiOCR-KOEN-G2M-Preview) · 관련 글 [G2M 공개](/tech-blog/ko/research/thakiocr-g2m-numbers-and-symbols/)
- **공개 상태**: 연구 프리뷰이며 판정은 A1_GEN2_NO_GO입니다. 금융·계약 문서의 금액, 계좌번호, 날짜 같은 중요 필드를 이 모델로 자동 처리하면 안 됩니다.

### ThakiOCR-KO-v1

- **규모**: 0.9B급 문서 OCR 모델 ATH-MaaS/OvisOCR3에 붙이는 LoRA 어댑터(rank 16, 디코더 전용, 학습 파라미터 639만 개, 25.6MB)입니다.
- **용도**: 한국어 단어 이미지 한 장을 글자로 옮깁니다. 손글씨, 인쇄체, 야외 촬영 글자를 학습했고 기반 모델의 표·읽기 순서 능력을 깨지 않도록 선택했습니다.
- **대표 지표**: 고정 개발 세트 단어 2,400개에서 CER이 기반 모델 25.28%에서 7.78%로 내려갔습니다.
- **평가 계약**: 개발 세트는 학습에 쓴 데이터셋 세 개의 공식 Validation 분할에서 원천별 600개씩 뽑았습니다. 같은 원천이므로 독립 시험 세트가 아닙니다. 탐욕적 디코딩, NFC 정규화와 공백 제거 뒤 CER로 쟀습니다. 문서 구조는 결과를 보기 전까지 열지 않은(봉인) 합성 표 50쪽에서 표 구조 정확 일치 1.00(기반 0.98)으로 "기반 모델보다 나빠지지 않았는가"만 확인했습니다.
- **속도·메모리**: B200 한 장, 배치 1에서 중앙값 0.210초, 최대 메모리 7.02GiB입니다.
- **한계**: 단어 단위로만 학습·평가했습니다. 실제 문서 전체 페이지를 읽는 품질은 독립 검증하지 않았습니다.
- **학습 데이터**: AI 허브(AI-Hub)의 대용량 손글씨 OCR 데이터(605), 다양한 형태의 한글 문자 이미지 인식 데이터(91), 야외 실제 촬영 한글 이미지 데이터(105)입니다. 데이터와 그 가공물은 재배포하지 않습니다.
- **라이선스**: Apache-2.0입니다. 기반 모델은 그 모델의 라이선스를 따릅니다.
- **링크**: [Hugging Face](https://huggingface.co/ThakiCloud/ThakiOCR-KO-v1) · 관련 글 [KO-v1 공개](/tech-blog/ko/research/thakiocr-ko-v1-ovisocr3-korean-finetune/)
- **공개 상태**: 연구 프리뷰입니다.

### ThakiOCR-Large-27B-R2B

- **규모**: Qwen/Qwen3.6-27B에 붙이는 LoRA 어댑터(rank 32, 디코더 선형층 496개, 학습 파라미터 2억 3,350만 개)입니다.
- **용도**: 한국어 단어 이미지 한 장을 글자로 옮기는 대형 모델 연구용입니다. 희귀 글자가 섞인 단어를 더 자주 뽑아 학습했습니다.
- **대표 지표**: 고정 개발 세트 단어 2,400개에서 CER이 기반 모델 18.04%에서 6.01%로 내려갔습니다. 단어 전체 일치율은 85.2%입니다.
- **평가 계약**: 개발 세트는 학습에 쓴 데이터셋 세 개의 공식 Validation 분할에서 원천별 600개씩 뽑았고 독립 시험 세트가 아닙니다. 파일·픽셀·원본 이미지 해시로 학습과 겹침이 없는지 확인했고 탐욕적 디코딩으로 쟀습니다. 차이의 신뢰구간은 결과를 보기 전에 정한 층화 쌍체 부트스트랩으로 냈습니다.
- **하드웨어**: bf16, 배치 1에서 GPU 메모리 약 53GB, B200 한 장에서 단어 하나당 중앙값 약 0.46초입니다.
- **한계**: 균등 추출 어댑터(R2-A) 대비 추가 개선 0.41%p는 통계적으로 경계선입니다.
- **학습 데이터**: KO-v1과 같은 AI 허브(AI-Hub) 데이터셋 605·91·105입니다. 데이터와 그 가공물은 재배포하지 않습니다.
- **라이선스**: Apache-2.0입니다. 기반 모델은 그 모델의 라이선스를 따릅니다.
- **링크**: [Hugging Face](https://huggingface.co/ThakiCloud/ThakiOCR-Large-27B-R2B) · 관련 글 [Large-27B-R2B 공개](/tech-blog/ko/research/thakiocr-large-27b-r2b-qwen-korean-ocr/)
- **공개 상태**: 연구 프리뷰입니다. 전문 OCR 모델보다 낫다고 주장하지 않습니다.

KO-v1과 Large-27B-R2B의 개발 세트는 구성 방식이 비슷하지만, 평가 이미지·전처리·디코딩·정답 처리가 같은지 검증하지 않았습니다. 그래서 두 모델을 이 숫자로 비교하지 않습니다.

네 카드 모두 GitHub 저장소 링크는 없습니다. 추론 코드는 각 저장소에 들어 있습니다(V1-Dense·G2M은 `inference.py`, KO-v1·Large-27B-R2B는 `inference_example.py`).

## 어떤 걸 골라야 하나

고르는 기준은 숫자 순위가 아니라 입력 단위와 하드웨어입니다.

- **GPU가 없고 줄 단위로 빠르게 읽어야 한다면** V1-Dense나 G2M을 봅니다. 둘 다 줄 검출기가 잘라 준 한 줄을 받습니다.
- **원화 기호, 원문자, 마스킹 숫자가 중요한 줄이라면** G2M을 봅니다. 다만 띄어쓰기가 들어간 날짜와 `₩`·`￦` 구분에는 약하므로 사람 확인 단계를 둡니다.
- **가장 가벼운 기준선이나 처음부터 학습하는 구조가 궁금하다면** V1-Dense를 봅니다. 합성 데이터만으로 학습했을 때 실문서에서 무엇이 무너지는지 보여 줍니다.
- **손글씨나 촬영 글자가 섞인 한국어 단어를 GPU 한 장(약 7GiB)으로 읽어야 한다면** KO-v1을 봅니다. 기반 모델의 표 구조 능력을 유지하는 쪽을 택한 어댑터입니다.
- **GPU 메모리 53GB 이상을 쓸 수 있고 대형 모델이 단어 OCR을 어디까지 배우는지 연구한다면** Large-27B-R2B를 봅니다.

모든 모델은 금융·법률·신분 문서의 중요 필드를 사람 확인 없이 읽는 용도로 쓰면 안 됩니다. 모델을 나눠 배치하는 방법은 [Metis 계층형 문서 추론 글](/tech-blog/ko/llmops/thakiocr-metis-tiered-document-inference/)에 정리했습니다. 검증 뒤에만 업무에 반영하는 흐름은 [Paxis 검증 워크플로 글](/tech-blog/ko/agentops/thakiocr-paxis-verify-before-commit/)에 정리했습니다.

## 연구에 쓰려면

1. **Hugging Face에서 받습니다.** 각 카드의 Files 표에 가중치, 설정, 추론 코드가 있습니다. 어댑터 모델은 카드에 적힌 기반 모델 리비전을 그대로 고정합니다.
2. **카드의 추론 코드로 먼저 재현합니다.** 카드에 적힌 전처리, 프롬프트, 디코딩 설정 밖에서는 평가하지 않았습니다. V1-Dense와 G2M은 `python inference.py --demo`로 바로 확인할 수 있습니다.
3. **문서를 읽습니다.** 카드의 Known limitations 절과 관련 블로그 글에 실패 유형과 평가 세트 구성이 있습니다. 네 모델이 왜 크기가 다른지는 [한국어 OCR 오픈소스 모델 4종 비교](/tech-blog/ko/research/korean-ocr-open-models-2m-to-27b/)에 정리했습니다.

## 도입을 검토한다면

1. **사용 사례를 정합니다.** 문서 종류, 입력 단위(줄·단어·페이지), 하루 처리량, 틀리면 안 되는 필드를 먼저 적습니다. 네 모델은 모두 페이지에서 글자 위치를 찾지 않으므로 검출 단계가 따로 필요합니다.
2. **보안·온프레미스 조건을 확인합니다.** 가중치를 내려받아 내부망에서 돌릴 수 있습니다. 학습과 서빙을 고객 환경 안에서 운영하는 구성은 [Maxis 학습 글](/tech-blog/ko/research/thakiocr-maxis-same-size-fewer-errors/)과 [Metis 계층형 추론 글](/tech-blog/ko/llmops/thakiocr-metis-tiered-document-inference/)에서 다룹니다.
3. **기술 문의를 남깁니다.** 자체 문서로 평가하거나 플랫폼에 올리는 상담은 [ThakiCloud](https://thakicloud.com)로 문의하시면 됩니다.

## 개발 중

{: .notice--info}
**개발 중인 모델입니다. 성능 수치는 공개하지 않습니다.**
**ThakiOCR-KO-v2**: 독립 평가에 쓸 문서·손글씨 데이터가 부족해 공식 평가를 하지 못했고 공개를 보류했습니다. 성능이 나빠서 보류한 것이 아닙니다.
**ThakiSight-Edge**: 학습을 진행하고 있습니다.

## 관련 글

아래 목록은 `thakiocr` 태그가 붙은 글 전체입니다. 주요 글은 다음과 같습니다.

- [ThakiOCR A: 213만 파라미터 자체 한국어·영어 OCR](/tech-blog/ko/research/thakiocr-a-small-korean-english-line-ocr/)
- [ThakiOCR G2M: 숫자와 기호를 더 정확하게 읽는 두 번째 공개 모델](/tech-blog/ko/research/thakiocr-g2m-numbers-and-symbols/)
- [ThakiOCR A2: 독립 평가 43,751줄에서 확인한 개선과 남은 한계](/tech-blog/ko/research/thakiocr-a2-independent-eval-43751-lines/)
- [같은 893만 파라미터인데 OCR 오류가 31% 줄었습니다](/tech-blog/ko/research/thakiocr-maxis-same-size-fewer-errors/)
- [ThakiOCR와 Metis로 설계하는 계층형 문서 추론](/tech-blog/ko/llmops/thakiocr-metis-tiered-document-inference/)
- [OCR이 금액을 잘못 읽었다면 에이전트는 어떻게 해야 할까](/tech-blog/ko/agentops/thakiocr-paxis-verify-before-commit/)
- [한국어 OCR 오픈소스 모델 4종 비교: 213만부터 27B까지](/tech-blog/ko/research/korean-ocr-open-models-2m-to-27b/)
