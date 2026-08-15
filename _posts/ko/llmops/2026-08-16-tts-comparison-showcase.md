---
title: "다국어 TTS 4종, 직접 들어보고 언어별로 고르세요"
excerpt: "한국어 문장 하나를 네 모델이 읽습니다. 같은 문장, 같은 조건, 같은 하네스입니다. 듣고 나서 표를 보시면 왜 VoxCPM2가 Qwen3-TTS보다 12배 빠른데도 감정 축에서는 표에 못 오르는지, 왜 금액을 읽히면 안 되는지가 한 번에 잡힙니다."
seo_title: "다국어 TTS 비교: 음성 샘플과 언어별 선택 가이드"
seo_description: "Qwen3-TTS, VoxCPM2, Supertonic-3, Kokoro-82M을 한국어 영어 중국어 일본어로 합성해 36개 샘플을 직접 들어봅니다. RTF, 전력, 정확도, 감정 표현력 실측과 언어별 선택 처방까지."
date: 2026-08-16
last_modified_at: 2026-08-16
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "headphones"
tags:
  - text-to-speech
  - multilingual-tts
  - audio-samples
  - model-selection
  - inference-serving
  - korean-tts
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/tts-comparison-showcase/"
---

한국어 문장 하나를 네 모델이 읽습니다. 같은 문장, 같은 조건, 같은 하네스입니다. 먼저 들어보시고
표를 보시면 나머지 이야기가 훨씬 빨리 들어옵니다.

> 오늘 회의는 오후에 삼층 회의실에서 시작합니다.

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-ko-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-ko-voxcpm2.mp3"></audio></p>
<p><strong>Supertonic-3</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-ko-supertonic-3.mp3"></audio></p>

세 음성의 차이가 들리셨다면, 그 차이가 숫자로는 이렇게 나옵니다.

### 성능 한눈에

| 모델 | 하드웨어 | 언어 | RTF (p95) | 한 장당 스트림 | gross J/오디오초 | GPU 유휴 | EFI | SER |
|---|---|---|---|---|---|---|---|---|
| VoxCPM2 | B200 | 4 | **0.1** (0.124) | 10.0 | 97.2 | 43.4% | n/a | n/a |
| Kokoro-82M | CPU 32c | 2 | **0.64** (1.344) | 1.6 | 301.1 | n/a | 0.0241 | 0.1667 |
| Qwen3-TTS-1.7B | B200 | 4 | **1.196** (1.306) | 0.8 | 815.8 | 86.7% | 0.4075 | 0.4028 |
| Supertonic-3 | CPU 32c | 3 | **2.497** (3.534) | 0.4 | 1581.2 | n/a | 0.2549 | 0.2222 |

### 언어별 정확도 (CER/WER 중앙 · p90)

| 모델 | ko | en | zh | ja |
|---|---|---|---|---|
| VoxCPM2 | 0.000 / 0.217 | 0.000 / 0.167 | 0.026 / 0.435 | 0.103 / 0.438 |
| Kokoro-82M | n/a | 0.000 / 0.107 | 0.040 / 0.438 | n/a |
| Qwen3-TTS-1.7B | 0.000 / 0.295 | 0.000 / 0.092 | 0.000 / 0.289 | 0.044 / 0.413 |
| Supertonic-3 | 0.000 / 0.292 | 0.000 / 0.175 | n/a | 0.008 / 0.321 |

### 언어별 UTMOS (⚠️ en 만 보정)

| 모델 | ko | en | zh | ja |
|---|---|---|---|---|
| VoxCPM2 | 2.9312 ⚠️ | 4.1584 | 3.2682 ⚠️ | 2.9821 ⚠️ |
| Kokoro-82M | n/a | 4.515 | 3.9564 ⚠️ | n/a |
| Qwen3-TTS-1.7B | 3.7056 ⚠️ | 4.3666 | 3.3001 ⚠️ | 3.3059 ⚠️ |
| Supertonic-3 | 3.9297 ⚠️ | 4.4752 | n/a | 4.1711 ⚠️ |

RTF는 낮을수록 빠릅니다. 1.0이면 1초짜리 음성을 만드는 데 1초가 걸린다는 뜻이라, 그 아래여야
실시간 대화에 쓸 수 있습니다. **VoxCPM2는 0.100으로 B200 한 장에서 열 스트림을 감당하고
Qwen3-TTS는 1.196이라 한 스트림도 못 따라갑니다.** 열두 배 차이입니다.

전력은 절대값으로 읽었습니다. Qwen3-TTS가 소비한 전력의 86.7%는 합성과 무관한 유휴분이라,
배치를 채우지 못하는 엔드포인트는 GPU를 통째로 태우면서 한 스트림을 만듭니다.

## 언어별로 이렇게 고르시면 됩니다

### 한국어

**실시간이면 VoxCPM2, 품질이면 Supertonic-3입니다.** VoxCPM2는 RTF 0.100으로 압도적이지만
UTMOS가 2.93으로 네 모델 중 가장 낮습니다. Supertonic-3은 3.93으로 가장 높은 대신 RTF 2.498이라
실시간의 두 배 반이 걸립니다. 안내 음성처럼 미리 만들어 두는 용도면 Supertonic이 맞고, 대화형이면
VoxCPM2에 품질을 양보하는 편이 낫습니다.

Kokoro-82M은 애초에 한국어를 지원하지 않습니다. 모델 카드가 주장하는 언어와 실제로 잰 언어를
따로 기록해 둔 이유입니다.

### 영어

**속도와 전력으로만 고르셔도 됩니다.** UTMOS가 4.16에서 4.52 사이로 네 모델이 좁게 몰려 있어
품질 차이가 크지 않습니다. CER도 전부 중앙값 0입니다. 그렇다면 남는 기준은 RTF와 전력이고,
그 축에서는 VoxCPM2가 GPU에서, Kokoro-82M이 CPU에서 각각 앞섭니다.

특히 Kokoro-82M은 영어와 중국어만 필요하다면 **GPU를 아예 쓰지 않는 선택지**입니다. CPU 32코어에서
RTF 0.640이니 실시간보다 빠릅니다.

### 중국어

**Qwen3-TTS가 안전합니다.** CER 중앙값 0에 p90도 0.289로, VoxCPM2의 0.435나 Kokoro의 0.438보다
꼬리가 훨씬 짧습니다. 중국어는 상위 10% 발화에서 갈리는 폭이 커서 중앙값만 보면 판단을 그르칩니다.

### 일본어

**어느 모델을 쓰든 p90을 확인하셔야 합니다.** Qwen3-TTS 0.413, VoxCPM2 0.438, Supertonic-3 0.321로
세 모델 모두 일본어에서 꼬리가 깁니다. 그나마 Supertonic-3이 가장 낫습니다. 일본어 안내 음성을
만드신다면 전량 검수를 예산에 넣으시는 편이 안전합니다.

## 금액과 전문용어를 읽히면 이렇게 됩니다

정확도 표의 중앙값은 전부 0에 가까운데 p90만 크게 튑니다. 오류가 고르게 퍼진 게 아니라 특정
범주에 몰려 있다는 뜻입니다. 범주별로 쪼개 보면 평문과 의문문, 복합문은 거의 완벽하고
**숫자와 전문용어에서만** 무너집니다.

실제로 틀린 발화들입니다. 원문과 들리는 소리를 비교해 보시면 어디서 깨지는지 바로 보입니다.

> (한국어, technical) 자세한 내용은 docs.thakicloud.net 문서를 참고해 주세요.

<p><strong>Qwen3-TTS n/a 오차 0.5641</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/b-ko-qwen3-tts-1.7b.mp3"></audio></p>

> (일본어, technical) 詳しくは docs.thakicloud.net のドキュメントをご参照ください。

<p><strong>Qwen3-TTS n/a 오차 0.5556</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/b-ja-qwen3-tts-1.7b.mp3"></audio></p>

> (중국어, numeric) 内存占用从六十四GB一夜之间涨到了一百二十八GB。

<p><strong>VoxCPM2 n/a 오차 0.5417</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/b-zh-voxcpm2.mp3"></audio></p>

> (일본어, numeric) メモリ使用量が六十四ギガバイトから百二十八ギガバイトに増えました。

<p><strong>VoxCPM2 n/a 오차 0.5312</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/b-ja-voxcpm2.mp3"></audio></p>

> (일본어, numeric) メモリ使用量が六十四ギガバイトから百二十八ギガバイトに増えました。

<p><strong>Supertonic-3 n/a 오차 0.5312</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/b-ja-supertonic-3.mp3"></audio></p>

> (중국어, numeric) 部署时间定在二零二六年八月十四日上午九点三十分。

<p><strong>Qwen3-TTS n/a 오차 0.4348</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/b-zh-qwen3-tts-1.7b.mp3"></audio></p>

기사를 읽어주는 용도라면 무해합니다. 다만 금액이나 일시, 제품 코드를 읽어야 하는 서비스라면
이 두 범주가 바로 사고 지점입니다. 숫자를 미리 한글로 풀어 넣는 전처리를 넣으시는 편이
모델을 바꾸는 것보다 확실합니다.

## 감정 지시가 먹는다는 게 무슨 뜻인가

같은 문장을 여섯 감정으로 합성했습니다. 위가 감정 표현력이 가장 높았던 모델이고, 아래가
감정 조절 기능 자체가 없는 모델입니다. 차이를 귀로 확인하시는 게 숫자보다 빠릅니다.

#### Qwen3-TTS

> 그 사람이 방금 문을 열고 들어왔어요.

<p><strong>중립</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-qwen3-tts-1.7b-neutral.mp3"></audio></p>
<p><strong>기쁨</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-qwen3-tts-1.7b-happy.mp3"></audio></p>
<p><strong>슬픔</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-qwen3-tts-1.7b-sad.mp3"></audio></p>
<p><strong>분노</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-qwen3-tts-1.7b-angry.mp3"></audio></p>
<p><strong>공포</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-qwen3-tts-1.7b-fear.mp3"></audio></p>
<p><strong>놀람</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-qwen3-tts-1.7b-surprise.mp3"></audio></p>

#### Kokoro-82M

> He just walked through the door a moment ago.

<p><strong>중립</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-en-kokoro-82m-neutral.mp3"></audio></p>
<p><strong>기쁨</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-en-kokoro-82m-happy.mp3"></audio></p>
<p><strong>슬픔</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-en-kokoro-82m-sad.mp3"></audio></p>
<p><strong>분노</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-en-kokoro-82m-angry.mp3"></audio></p>
<p><strong>공포</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-en-kokoro-82m-fear.mp3"></audio></p>
<p><strong>놀람</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-en-kokoro-82m-surprise.mp3"></audio></p>

Kokoro-82M 쪽은 여섯 개가 사실상 같은 소리입니다. 이 모델에는 감정 조절 API가 없어서 여섯 조건이
같은 입력이기 때문입니다. 그래서 이 모델이 **지표의 바닥**이 됩니다. 프로소디 분산을 재는 EFI가
0.024, 감정 분류기가 요청한 감정을 맞히는 비율이 0.167이 나오는데, 뒤 숫자는 여섯 감정을 균등하게
찍었을 때의 우연 확률과 정확히 같습니다.

바닥을 알고 나면 Qwen3-TTS의 EFI 0.408은 바닥의 17배, SER 0.403은 우연의 2.4배로 읽힙니다.
다만 절대 수준은 낮게 보셔야 합니다. 가장 잘한 모델조차 요청한 감정이 분류기까지 전달되는 비율이
절반을 넘지 못합니다. **감정 지시는 켜면 그 감정이 되는 스위치가 아니라 그쪽으로 조금 기울이는
손잡이입니다.**

## 나머지 언어 샘플

#### 한국어

> 오늘 회의는 오후에 삼층 회의실에서 시작합니다.

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-ko-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-ko-voxcpm2.mp3"></audio></p>
<p><strong>Supertonic-3</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-ko-supertonic-3.mp3"></audio></p>

#### 영어

> The meeting will start this afternoon in the third floor conference room.

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-en-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-en-voxcpm2.mp3"></audio></p>
<p><strong>Supertonic-3</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-en-supertonic-3.mp3"></audio></p>
<p><strong>Kokoro-82M</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-en-kokoro-82m.mp3"></audio></p>

#### 중국어

> 会议将在今天下午于三楼会议室举行。

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-zh-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-zh-voxcpm2.mp3"></audio></p>
<p><strong>Kokoro-82M</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-zh-kokoro-82m.mp3"></audio></p>

#### 일본어

> 会議は今日の午後、三階の会議室で始まります。

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-ja-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-ja-voxcpm2.mp3"></audio></p>
<p><strong>Supertonic-3</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-ja-supertonic-3.mp3"></audio></p>

## 이 숫자들의 한계

전부 같은 하네스로 쟀고 원장을 남겼습니다. 다만 정직하게 밝힐 것이 셋 있습니다.

UTMOS는 영어로 학습된 예측기라 한국어와 중국어, 일본어 값은 보정되지 않았습니다. 같은 언어 안에서
모델을 줄 세우는 데는 쓸 수 있지만 언어끼리 비교하시면 안 됩니다. 표에 물음표를 달아 둔 칸이
그것입니다.

CPU 두 모델의 전력은 공유 노드에서 쟀습니다. 같은 설정을 세 번 반복하니 순증분 전력이 178%
흔들렸습니다. 그래서 표에는 절대값만 실었고, CPU 모델끼리의 전력 비교는 하지 않았습니다.

로스터에 올린 열두 모델 중 넷만 완주했습니다. 나머지는 파이썬 API 계약이 확인되지 않았거나
레포를 클론해 설치해야 하는 종류라 이번 편에 넣지 못했습니다. 다음 편에서 다루겠습니다.

---

샘플 36개는 모두 이 실험에서 나온 실제 합성 결과이고, 후처리나 선별 없이 원장이 가리키는 파일을
그대로 mp3로 변환했습니다.
