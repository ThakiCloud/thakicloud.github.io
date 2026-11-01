---
title: "ATT&CK 기법 검색·근거 게이트·엣지 스킬 검색 3종을 공개합니다: 미달한 게이트까지 그대로"
excerpt: "MITRE ATT&CK 문서를 찾는 보안 임베딩, RAG가 답할지 멈출지 정하는 근거 게이트, CPU에서 도는 스킬 검색 임베딩 세 가지입니다. 셋 중 둘은 공개 전에 걸어 둔 기준을 넘지 못했습니다. 어디서 얼마나 못 넘었는지 숫자로 적었습니다."
seo_title: "Thaki-SecEmbed-8B·ECP-SB-27B·SKILLRET-Edge-305M 공개 - ThakiCloud"
seo_description: "다키클라우드가 공개한 세 모델을 정리했습니다. Thaki-SecEmbed-8B는 MITRE ATT&CK 기법 검색만 평가했습니다. 사전등록 평가에서는 기본 모델과 분명한 차이가 없었고, 공개 결정 뒤에 잰 독립 출제 벤치에서는 기본 모델보다 nDCG@10이 +0.1447 높았습니다. ECP-SB-27B는 미답변율 6.5%로 5% 목표를 넘지 못했습니다. SKILLRET-Edge-305M은 게이트를 통과해 CPU에서 47.7ms에 답합니다."
date: 2026-10-25
last_modified_at: 2026-11-01
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cube"
tags:
  - security
  - mitre-attack
  - embedding
  - retrieval
  - rag
  - evidence-gate
  - abstention
  - skill-retrieval
  - onnx
  - cpu
  - open-weight
  - paxis
categories:
  - owm
canonical_url: "https://thakicloud.com/tech-blog/ko/owm/preregistered-gates-three-models-open/"
header:
  teaser: /assets/images/secembed-two-verdicts.webp
---

사내망에서 MITRE ATT&CK 기법 문서를 찾아야 하거나, RAG가 근거 없이 답하는 것을 막아야 하거나, 에이전트가 쓸 스킬을 CPU에서 골라야 하는 분께 드리는 글입니다. 이번에 공개하는 세 모델이 각각 그 한 칸을 맡습니다.

먼저 밝혀 둘 것이 있습니다. 셋 중 둘은 학습을 시작하기 전에 걸어 둔 합격선을 넘지 못했습니다. 다키클라우드는 그 사실을 지우지 않고 모델 카드 첫 화면에 적은 뒤 그대로 공개했습니다. 아래 숫자를 보시고 쓸지 말지 정하시면 됩니다.

## 쉽게 말하면

시험 문제를 누가 냈느냐에 따라 같은 학생의 점수가 달라집니다. 선생님이 수업에서 쓰던 문제집으로 시험을 내면 그 수업을 들은 학생이 유리합니다. 다른 학교 선생님이 낸 문제로 보면 실력이 더 솔직하게 드러납니다.

모델 평가도 같습니다. 학습 문제를 만든 그 생성기로 시험 문제까지 만들면, 점수가 올라도 실력이 올랐다고 말하기 어렵습니다. 그래서 다키클라우드는 공개 여부를 정하는 합격선을 학습 전에 글로 적어 둡니다. 결과가 나온 뒤에는 그 선을 고치지 않습니다. 이번 세 모델 중 하나는 그 선을 넘었고, 둘은 넘지 못했습니다.

## 세 모델이 서는 자리

```mermaid
flowchart TB
    Q["보안 분석가 질의<br/>한국어·영어"] --> SE["Thaki-SecEmbed-8B<br/>ATT&CK 기법 문서 검색<br/>(평가한 유일한 말뭉치)"]
    SE --> G[ECP-SB-27B<br/>근거 게이트<br/>답한다·더 찾는다·답하지 않는다]
    G --> A["생성 응답"]
    AG[에이전트 작업 요청] --> SK[SKILLRET-Edge-305M<br/>스킬 검색 · CPU]
    SK --> AG
```

왼쪽 줄기는 보안 질의가 지나가는 길입니다. 임베딩이 관련 ATT&CK 기법 문서를 찾아 오면, 게이트가 그 근거로 답해도 되는지를 먼저 판정합니다. SecEmbed를 평가한 말뭉치는 ATT&CK 기법 문서뿐입니다. CTI 보고서, 로그와 텔레메트리, 탐지 룰, 취약점 DB는 평가하지 않았습니다. 실제 보안 파이프라인의 다른 문서에는 그 문서로 측정한 검색기를 붙여야 합니다. 오른쪽 줄기는 에이전트가 수천 개 스킬 중 지금 쓸 것을 고르는 길입니다. GPU 없이 돌아갑니다.

## 같은 어댑터에 판정이 두 개 나왔습니다

Thaki-SecEmbed-8B-Preview는 Qwen3-Embedding-8B에 LoRA를 얹어 MITRE ATT&CK 기법 문서를 찾게 만든 어댑터입니다. 학습에는 공개 데이터인 MITRE ATT&CK STIX(Enterprise ATT&CK v19.2)만 썼고, 사내 데이터와 고객 데이터는 넣지 않았습니다. 모델 카드가 평가한 과제는 하나입니다. 영어와 한국어로 된 분석가식 질의로 ATT&CK 기법 문서의 순위를 매기는 일입니다. 아래 숫자는 보안 검색 전반의 성능이 아닙니다.

![같은 어댑터, 서로 다른 두 판정](/assets/images/secembed-two-verdicts.webp)

공개 판정의 근거가 된 것은 왼쪽입니다. 583문항짜리 사전등록 held-out에서 nDCG@10이 0.686으로 기본 모델 0.670보다 높았습니다. 차이는 +0.016이고 95% 신뢰구간 [-0.010, +0.043]이 0을 포함했습니다. 같은 세트에서 Recall@10은 0.859였고, 기본 모델은 0.842, BM25는 0.427이었습니다. 이 세트는 범위가 좁습니다. 상위 기법 17개만 다루고, 질의도 학습 질의와 같은 생성기와 분포에서 나왔습니다. 그래서 이 값은 분포 안의 ATT&CK 기법 검색 성능이지 실제 분석가 질의 성능이 아닙니다. 판정은 분명한 차이 없음입니다. 저희는 개선을 주장하지 않습니다. 세 개 시드를 따로 학습해 보니 점수가 0.676에서 0.705까지 흩어졌는데, 이 흔들림이 기본 모델과의 차이만큼 컸습니다. 주장을 접은 이유가 여기에 있습니다. 근거를 찾는 에이전트가 자주 쓰는 질의 유형 두 개는 기본 모델 대비 점추정이 음수였습니다. analyst_search가 -0.035, evidence_request가 -0.018입니다. 둘 다 유의한 퇴행은 아닙니다.

오른쪽은 공개한 뒤에 잰 값입니다. Blind-B는 학습 교사와 다른 모델들이 문제를 내고 정답은 ATT&CK STIX 관계로 코드가 정하는 2,025문항 벤치입니다. 출처 anchor는 966개입니다. 여기서는 0.694 대 0.550으로 벌어졌습니다. 짝지은 차이는 +0.1447이고 95% 신뢰구간은 +0.129에서 +0.161입니다(anchor cluster bootstrap). 영어와 한국어에서 방향이 같았습니다. Nemotron-3-Embed-8B는 Blind-B에서 0.587이었습니다. 신뢰구간은 기본 모델과만 계산했으므로, 카드는 Nemotron보다 분명히 낫다고 주장하지 않습니다. 두 결과는 모순이 아니라 같은 이야기의 두 면입니다. 학습과 같은 출제기로 만든 문제는 두 모델을 가르지 못했습니다. 독립 출제기로 만든 문제는 갈랐습니다. 다만 이 측정은 공개 결정 뒤에 나왔으므로 사전등록 판정을 뒤집지 않습니다. Blind-B 역시 ATT&CK 기법 검색입니다. 그 과제 안에서 근거를 넓혀 줄 뿐, 다른 보안 말뭉치에 대해서는 아무것도 말해 주지 않습니다.

대가도 있습니다. 일반 검색 성능을 공개 검색셋 네 개로 확인했고, 세트마다 따로 판정했습니다.

| 세트 | 기본 모델 nDCG@10 | SecEmbed nDCG@10 | Δ [95% CI] | 상대 변화 |
|---|---|---|---|---|
| SciFact | 0.784 | 0.797 | +0.013 [+0.001, +0.026] | +1.7% |
| NFCorpus | 0.409 | 0.417 | +0.008 [+0.001, +0.015] | +2.0% |
| FiQA-2018 | 0.650 | 0.610 | -0.040 [-0.052, -0.029] | -6.2% |
| MIRACL (ko) | 0.667 | 0.674 | +0.006 [-0.008, +0.023] | +1.0% |

나쁜 쪽으로 움직인 것은 금융 질의응답인 FiQA-2018입니다. 사전등록한 파국 기준인 10%에는 못 미치지만 통계적으로 분명한 하락입니다. 금융 문서를 찾는 자리라면 기본 모델을 쓰시는 편이 낫습니다. 한국어 검색인 MIRACL에서는 분명한 변화가 없었습니다. 네 세트를 통과했다고 해서 일반 능력이 유지된다는 근거가 되지는 않습니다.

## 안전장치로 쓰지 말라고 적었습니다

ECP-SB-27B-Research는 H200 한 장에 Qwen3.8-27B를 한 번만 올려 두 개의 API를 띄우는 패키지입니다. 하나는 평범한 생성입니다. 다른 하나는 검색 직후 생성 직전에 답할지, 더 찾을지, 답하지 않을지를 정하는 근거 게이트입니다. 기본 가중치는 복사하지 않고 네 개 시드의 LoRA와 판정 머리, 봉인한 임계값만 담았습니다.

배포 점검은 통과했습니다. 기본 모델만 서빙하는 vLLM과 같은 조건으로 비교했을 때 생성 전용 트래픽은 기준 안에 들었습니다. 게이트 요청 256건은 오프라인 기준값과 한 건도 달라지지 않았습니다. 다만 p99 로그확률 격차가 기준선을 0.00000286 차이로 통과했습니다. 통과는 통과이되 여유가 없었습니다. 그래서 혼합 트래픽에서 생성이 기본 모델과 똑같다고는 적지 않았습니다. 64개 중 6개가 달랐고 원인을 귀속하지 못했기 때문입니다.

넘지 못한 선은 따로 있습니다. 근거가 모자란데도 답해 버린 비율이 시드 묶음 기준 6.5%입니다. 목표는 5%였습니다. 0.047부터 0.093까지 시드마다 편차도 컸습니다. 그래서 모델 카드에는 이 게이트를 안전 통제 수단으로 쓰지 말라고 적었습니다. 연구 배포이고 프로덕션 인증이 아닙니다.

| 점검 항목 | 결과 |
|---|---|
| 기본 가중치 1회 적재, 단일 GPU 프로세스 | 통과 |
| 생성 API와 게이트 API 동시 응답 | 통과 |
| 혼합 트래픽에서 게이트 판정 256건 | 통과, 변동 0건 |
| 혼합 트래픽에서 생성이 기본과 동일 | 미입증, 64건 중 6건 상이 |
| 프로덕션 안전성 | 미인증, 미답변율 6.5% 대 목표 5% |

## 통과한 쪽은 CPU에서 돕니다

SKILLRET-Edge-Arctic-305M은 에이전트가 쓸 스킬을 찾는 305M 임베딩입니다. 8B 교사에서 증류했고 ONNX FP32로 CPU에서 돕니다. 사전등록 게이트는 영어 품질을 지키면서 한국어를 올리는 것입니다. 둘 다 넘었습니다. 공개 테스트 분할에서 영어 nDCG@10이 0.6B 기준선보다 1.07점 높았습니다. 한국어는 저비트 비교 대상보다 11.99점 높았습니다.

쓸 자리를 가르는 숫자는 품질보다 지연과 메모리입니다.

| 호스트 | 스레드 | 이 모델(ONNX FP32) p50 | 최대 RSS | 0.6B Q4_1(llama-server) p50 | 최대 RSS |
|---|---|---|---|---|---|
| AMD EPYC 9355 | 1 | 133.8 ms | 2.0 GB | 1,973 ms | 3.58 GB |
| AMD EPYC 9355 | 4 | 47.7 ms | 2.1 GB | 582 ms | 3.58 GB |
| Apple M4 Pro | 1 | 36.0 ms | 3.0 GB | 2,073 ms | 3.58 GB |

다만 이 표는 가중치 둘이 아니라 서빙 구성 둘을 비교한 것입니다. 오른쪽은 슬롯 16개를 잡아 둔 HTTP 서버라 메모리 대부분이 KV와 연산 버퍼입니다. 양자화 기법 자체가 느리다는 뜻이 아닙니다. 그리고 INT8 빌드는 없습니다. 동적 INT8과 정적 QDQ INT8 모두 품질 게이트를 통과하지 못해 FP32만 올렸습니다. ONNX 파일이 1.23GB이니 휴대폰에 넣을 크기가 아닙니다. CPU 서버에서 쓰는 빠른 검색기로 보시면 맞습니다.

## 서빙할 때 알아 두실 것

SecEmbed는 어댑터라 기본 모델과 함께 올려야 합니다. 기본 모델은 Qwen/Qwen3-Embedding-8B의 revision `1d8ad4ca9b3dd8059ad90a75d4983776a23d44af`입니다. `v0.0.1` 태그부터는 `adapter_config.json`에 이 기본 모델과 revision이 적혀 있어 PEFT 자동 로딩이 됩니다. `v0.0.0`은 설정의 기본 모델 경로가 학습 때의 로컬 경로라서 기본 모델을 직접 지정해 올려야 합니다. 기본 차원은 4096입니다. 잘라 쓰는 차원(1024, 512, 256)은 MRL로 학습하지 않았습니다. 카드는 이 값을 [한국어 모델 카드](https://huggingface.co/ThakiCloud/Thaki-SecEmbed-8B-Preview/blob/main/MODEL_CARD.ko.md)의 차원 절에 진단용으로만 적어 두었습니다. 학습은 Enterprise ATT&CK v19.2로 했습니다. 이후 추가되거나 이름이 바뀌거나 폐기된 기법은 반영되지 않았으니, ATT&CK 버전을 올리면 색인을 다시 만들고 검색 품질도 다시 확인해야 합니다. ECP-SB는 vLLM 0.28.0에서만 검증했습니다. 0.31 이식은 계획만 있고 검증되지 않았으며, 게이트 분기가 모든 토큰마다 돌기 때문에 비용도 공짜가 아닙니다. SKILLRET-Edge는 반대로 가장 간단합니다. 질의에 `query: ` 접두사를 붙이고 ONNX Runtime으로 부르면 끝입니다. 출력은 그래프 안에서 이미 L2 정규화됩니다.

SecEmbed 카드의 사용법을 줄여 옮겼습니다. 지시문은 질의에만 붙이고 문서는 원문 그대로 임베딩합니다. 풀링은 왼쪽 패딩 기준 마지막 토큰을 쓰고, 그다음 L2 정규화를 합니다.

```python
import torch
import torch.nn.functional as F
from peft import PeftModel
from transformers import AutoModel, AutoTokenizer

INSTRUCTION = ("Given a security analyst query, retrieve documentation of the adversary "
               "technique or tactic it describes.")

BASE, REV = "Qwen/Qwen3-Embedding-8B", "1d8ad4ca9b3dd8059ad90a75d4983776a23d44af"
tok = AutoTokenizer.from_pretrained(BASE, revision=REV, padding_side="left")
base = AutoModel.from_pretrained(BASE, revision=REV, torch_dtype=torch.bfloat16)
model = PeftModel.from_pretrained(base, "ThakiCloud/Thaki-SecEmbed-8B-Preview").eval()

def embed(texts, max_len):
    enc = tok(texts, padding=True, truncation=True, max_length=max_len, return_tensors="pt")
    with torch.no_grad():
        h = model(**enc).last_hidden_state[:, -1]          # last token (left padding)
    return F.normalize(h.float(), p=2, dim=-1)

q = embed([f"Instruct: {INSTRUCTION}\nQuery: {x}" for x in ["Can malware download files from the C2?"]], 512)
d = embed(["<ATT&CK technique document text>"], 2048)     # documents: raw text, no instruction
scores = q @ d.T
```

세 모델의 가중치는 모두 Apache-2.0입니다. 학습 데이터 조건은 모델마다 다릅니다. SecEmbed의 학습 데이터는 MITRE ATT&CK에서 만들었고, [ATT&CK 이용 약관](https://attack.mitre.org/resources/legal-and-branding/terms-of-use/)에 따라 썼습니다. 이 약관은 오픈소스 라이선스가 아닙니다. SecEmbed 저장소는 ATT&CK 콘텐츠를 재배포하지 않습니다. 나머지 두 모델의 데이터 조건은 각 모델 카드에서 확인해 주십시오. 폐쇄망에 그대로 들여놓을 수 있는 근거는 가중치 라이선스입니다. 색인에 넣는 ATT&CK 콘텐츠에는 여전히 ATT&CK 이용 약관이 적용됩니다.

## 왜 미달한 것까지 공개하는가

보안과 금융 쪽 고객이 가장 먼저 묻는 질문은 성능이 아니라 "이 숫자를 누가 어떻게 쟀는가"입니다. 통과한 것만 공개하면 그 질문에 답할 수 없습니다. 합격선을 먼저 적고 결과가 나온 뒤 그 선을 고치지 않는 방식은 자랑이 줄어드는 대신 숫자의 수명이 길어집니다.

다키클라우드가 만드는 엔터프라이즈 에이전트 플랫폼 Paxis는 에이전트의 모든 실행을 정책 게이트와 감사 기록으로 통과시킵니다. 근거가 모자랄 때 멈추는 판단은 그 구조의 앞단에 들어갈 재료입니다. 스킬 검색기는 수천 개 스킬 중 지금 쓸 것을 고르는 자리에 들어갑니다. 다만 이번 세 모델은 아직 어떤 제품에도 들어가 있지 않습니다. SecEmbed도 지금 Paxis나 추론·서빙 계층인 Metis에 들어가 있지 않고, 서빙 지연이나 처리량 수치도 공개하지 않았습니다. 나중에 가능한 구성은 아직 만들지도 재지도 않았습니다. 그 구성이라면 생성 모델 옆에 별도 임베딩 엔드포인트로 올리고, 위의 기본 모델 revision과 어댑터 sha256(`e49c221ae93b931b93d4616aedd8808dc95e9ee4271d63f55e79b104656f5933`)으로 고정합니다. 그러면 감사 기록에 어떤 검색기가 근거를 골랐는지 정확히 남길 수 있습니다. 세 번째 모델이 GPU 없이 CPU에서 47.7ms에 답한다는 점은 온프렘과 폐쇄망 환경에서 특히 쓸모가 있습니다. GPU 한 장 없이도 에이전트의 스킬 선택 단계를 돌릴 수 있기 때문입니다.

## 다음에 무엇을 재나

ECP-SB는 vLLM 0.31 이식과 함께, 같은 접두사를 두 번 계산하지 않도록 forward를 재사용하는 작업이 걸려 있습니다. 미답변율은 별도의 독립 평가로 다시 잽니다. 목표를 못 넘긴 숫자는 다음 측정으로 갱신하지, 지난 숫자를 고쳐 쓰지 않습니다.

SKILLRET-Edge는 다국어 확장과 더 작은 학생 모델이 다음 순서입니다. 22M급 학생을 INT8로 22.7MB까지 줄이는 쪽을 봅니다. 네 개 임베더 계열에 걸친 사후 양자화 비교는 논문으로 정리합니다.

SecEmbed는 Preview 상태를 유지합니다. Blind-B는 한 번 썼으니 이제 블라인드가 아니라 회귀 벤치로만 씁니다. 다음 판정은 새 블라인드 셋으로 받아야 합니다. 그 전에 FiQA 하락을 줄이는 일이 숙제로 남습니다.

## 공개한 것

| 저장소 | 형식 | 상태 |
|---|---|---|
| [ThakiCloud/Thaki-SecEmbed-8B-Preview](https://huggingface.co/ThakiCloud/Thaki-SecEmbed-8B-Preview) | LoRA 어댑터 | 프리뷰, ATT&CK 기법 검색만 평가, 사전등록 판정은 차이 없음, FiQA-2018 -0.040 |
| [ThakiCloud/ECP-SB-27B-Research](https://huggingface.co/ThakiCloud/ECP-SB-27B-Research) | 시드 가중치와 매니페스트 | 연구 배포, 프로덕션 미인증 |
| [ThakiCloud/SKILLRET-Edge-Arctic-305M](https://huggingface.co/ThakiCloud/SKILLRET-Edge-Arctic-305M) | ONNX FP32와 PyTorch | 사전등록 게이트 통과 |

평가를 먼저 적고 결과를 나중에 보는 순서를 지키면, 좋은 소식과 나쁜 소식이 같은 무게로 남습니다. 이번 공개에서 지키고 싶었던 것은 세 모델의 점수가 아니라 그 순서였습니다.

SecEmbed의 한국어 모델 카드는 [MODEL_CARD.ko.md](https://huggingface.co/ThakiCloud/Thaki-SecEmbed-8B-Preview/blob/main/MODEL_CARD.ko.md)에 있습니다.

*측정 출처: 세 모델의 Hugging Face 모델 카드에 공개된 평가표입니다. ECP-SB 배포 점검은 H200-NVL 한 장과 vLLM 0.28.0, SKILLRET-Edge CPU 측정은 AMD EPYC 9355와 Apple M4 Pro에서 쟀습니다.*

*MITRE ATT&CK®은 The MITRE Corporation의 등록 상표입니다. Thaki-SecEmbed-8B는 The MITRE Corporation과 제휴하거나 후원 또는 보증을 받은 모델이 아닙니다.*

## 업데이트 내역

**2026-11-01, Thaki-SecEmbed-8B-Preview에 관한 정정입니다.** ECP-SB-27B와 SKILLRET-Edge 부분은 바꾸지 않았습니다.

- 데이터 조건: 학습에 쓴 외부 데이터가 모두 공개 라이선스라고 적었던 문장을 고쳤습니다. SecEmbed의 데이터는 MITRE ATT&CK이고 ATT&CK 이용 약관에 따라 썼습니다. 이 약관은 오픈소스 라이선스가 아니며, 저장소는 ATT&CK 콘텐츠를 재배포하지 않습니다. MITRE ATT&CK® 상표 고지도 넣었습니다.
- 기본 모델: 고정 revision `1d8ad4ca9b3dd8059ad90a75d4983776a23d44af`와 `v0.0.0`, `v0.0.1`의 로딩 차이를 적었습니다.
- 평가 범위: 제목, 첫 문단, 그림, 본문에서 SecEmbed는 ATT&CK 기법 검색만 평가했다고 밝혔습니다. CTI 보고서, 로그와 텔레메트리, 탐지 룰, 취약점 DB는 평가하지 않았습니다.
- 카드에서 가져와 더한 숫자: held-out 신뢰구간과 Recall@10(0.859, 583문항 ATT&CK held-out 기준), 상위 기법 17개라는 좁은 범위, Blind-B 신뢰구간과 Nemotron 관련 단서, 두 질의 유형의 음수 점추정, MIRACL (ko)를 포함한 네 보존 세트 전체입니다.
- 카드의 사용법을 짧게 옮기고 ATT&CK v19.2 버전 안내를 더했습니다.
- 지금 들어가 있는 것(Paxis와 Metis 모두 없음)과 나중에 가능한 서빙 구성을 나눠 적었습니다.
- 한국어 모델 카드 링크를 더했습니다.
