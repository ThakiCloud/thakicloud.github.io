---
title: "다국어 TTS 5종 들어보기: 한국어 영어 중국어 일본어, 어느 모델을 쓸까"
excerpt: "Qwen3-TTS, VoxCPM2, Zonos, Supertonic-3, Kokoro-82M이 같은 문장을 네 개 언어로 읽습니다. 61개 음성 샘플을 언어별로 나란히 듣고 어느 모델이 내 언어에 맞는지 직접 판단하실 수 있게 정리했습니다."
seo_title: "다국어 TTS 모델 비교: 음성 샘플로 듣는 한국어 영어 중국어 일본어"
seo_description: "Qwen3-TTS, VoxCPM2, Zonos, Supertonic-3, Kokoro-82M의 한국어 영어 중국어 일본어 합성 음성을 직접 들어보고 언어별로 어느 모델을 선택할지 결정하실 수 있습니다. 61개 샘플과 실측 지표를 함께 제공합니다."
date: 2026-08-16
last_modified_at: 2026-08-16
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "headphones"
header:
  teaser: /assets/images/tts-comparison-showcase-hero.webp
tags:
  - text-to-speech
  - multilingual-tts
  - korean-tts
  - model-selection
  - audio-samples
  - inference-serving
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/tts-comparison-showcase/"
audiobook: "https://drive.google.com/file/d/1eC_HNrx9NR3zGA6gcWG4VYbVBSZ3_iFT/view"
audiobook_label: "▶ 5분 브리핑으로 듣기"
audiobook_note: "NotebookLM 오디오 개요 (AI 생성)"
---

![다국어 TTS 비교]({{ site.url }}{{ site.baseurl }}/assets/images/tts-comparison-showcase-hero.webp)
*여섯 개 모델이 같은 문장을 네 개 언어로 읽습니다*

음성합성 모델을 고르실 때 가장 확실한 방법은 직접 들어보는 것입니다. 그래서 여섯 개 모델에게
같은 문장을 한국어와 영어, 중국어, 일본어로 읽히고 **68개 샘플을 언어별로 나란히** 놓았습니다.
쓰실 언어 절만 보셔도 됩니다.

먼저 결론부터 말씀드리면 이렇습니다.

| 언어 | 실시간이 필요하면 | 품질이 우선이면 | 피할 것 |
|---|---|---|---|
| 한국어 | VoxCPM2 (RTF 0.100) | Supertonic-3 | Kokoro (미지원) |
| 영어 | Kokoro-82M (CPU로 충분) | 아무거나 (차이 작음) | 없음 |
| 중국어 | VoxCPM2 | Qwen3-TTS | **Zonos (깨짐)** |
| 일본어 | VoxCPM2 | Supertonic-3 | 전 모델 검수 필요 |

![다국어 TTS 5종 들어보기: 한국어 영어 중국어 일본어, 어느 모델을 쓸까 개념을 형상화한 이미지](/assets/images/tts-comparison-showcase-hero.webp)
*글의 핵심 개념을 형상화했습니다.*

## 한국어

다섯 모델이 지원합니다. Kokoro-82M은 한국어를 지원하지 않아 빠져 있습니다.

> 오늘 회의는 오후에 삼층 회의실에서 시작합니다.

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-ko-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-ko-voxcpm2.mp3"></audio></p>
<p><strong>Zonos</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-ko-zonos2.mp3"></audio></p>
<p><strong>Supertonic-3</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-ko-supertonic-3.mp3"></audio></p>
<p><strong>Chatterbox-ML</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-ko-chatterbox-ml.mp3"></audio></p>

> 어제 회의에서 결정된 내용을 반영해 초안을 수정했지만, 검토가 아직 끝나지 않아서 오늘 배포는 어려울 것 같습니다.

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-ko-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-ko-voxcpm2.mp3"></audio></p>
<p><strong>Zonos</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-ko-zonos2.mp3"></audio></p>
<p><strong>Supertonic-3</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-ko-supertonic-3.mp3"></audio></p>
<p><strong>Chatterbox-ML</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-ko-chatterbox-ml.mp3"></audio></p>

**Supertonic-3이 가장 또렷합니다.** 자연성 하위 축에서 명료도가 63.84로 가장 높고, 다른 언어에서도 비슷한 수준을 유지합니다. 대신 RTF 2.498이라 실시간의 두 배 반이 걸리니 미리 만들어 두는 안내 음성에 맞습니다.

실시간이 필요하시면 VoxCPM2가 RTF 0.100으로 압도적입니다. 다만 명료도가 48.63으로 가장 낮습니다. 같은 언어에서 Qwen3-TTS는 61.46이니 13점 차입니다. 목소리 자체는 가장 사람 같은데(화자 축 71.79로 최고) 음소가 뭉개지는 조합이라, 숫자나 코드를 읽히실 계획이면 전처리를 반드시 붙이셔야 합니다.

Zonos는 RTF 0.592로 실시간을 지키는 중간 선택지입니다. 감정 지시를 받기는 하지만 뒤에서 보시듯
요청한 감정으로 가지는 않으니, 감정이 목적이라면 권하지 않습니다.


![tts-comparison-showcase 슬라이드 1](/assets/images/tts-comparison-showcase-slide-01.webp)

## 영어

다섯 모델 모두 지원합니다.

> The meeting will start this afternoon in the third floor conference room.

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-en-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-en-voxcpm2.mp3"></audio></p>
<p><strong>Zonos</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-en-zonos2.mp3"></audio></p>
<p><strong>Supertonic-3</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-en-supertonic-3.mp3"></audio></p>
<p><strong>Chatterbox-ML</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-en-chatterbox-ml.mp3"></audio></p>
<p><strong>Kokoro-82M</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-en-kokoro-82m.mp3"></audio></p>

> I revised the draft to reflect what we decided yesterday, but since the review is not finished, shipping today seems unlikely.

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-en-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-en-voxcpm2.mp3"></audio></p>
<p><strong>Zonos</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-en-zonos2.mp3"></audio></p>
<p><strong>Supertonic-3</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-en-supertonic-3.mp3"></audio></p>
<p><strong>Chatterbox-ML</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-en-chatterbox-ml.mp3"></audio></p>
<p><strong>Kokoro-82M</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-en-kokoro-82m.mp3"></audio></p>

**품질로는 잘 안 갈립니다.** 자연성 종합이 70.09에서 76.45 사이로 좁게 몰려 있고 받아쓰기 오류도 전부 중앙값 0입니다. 그렇다면 남는 기준은 속도와 비용입니다.

그 축에서 눈에 띄는 것이 **Kokoro-82M입니다.** CPU 32코어에서 RTF 0.640으로 실시간보다 빠르면서 자연성 73.87을 냅니다. GPU 모델들과 3점 차 안쪽입니다. 영어와 중국어만 필요하시다면 GPU를 아예 쓰지 않는 구성이 가능합니다.


## 중국어

네 모델이 지원한다고 주장하지만, 실제로 쓸 수 있는 것은 셋입니다.

> 会议将在今天下午于三楼会议室举行。

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-zh-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-zh-voxcpm2.mp3"></audio></p>
<p><strong>Zonos</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-zh-zonos2.mp3"></audio></p>
<p><strong>Chatterbox-ML</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-zh-chatterbox-ml.mp3"></audio></p>
<p><strong>Kokoro-82M</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-zh-kokoro-82m.mp3"></audio></p>

> 我已经按照昨天的决定修改了草稿，但因为评审还没结束，今天上线恐怕来不及。

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-zh-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-zh-voxcpm2.mp3"></audio></p>
<p><strong>Zonos</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-zh-zonos2.mp3"></audio></p>
<p><strong>Chatterbox-ML</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-zh-chatterbox-ml.mp3"></audio></p>
<p><strong>Kokoro-82M</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-zh-kokoro-82m.mp3"></audio></p>

**Qwen3-TTS가 안전합니다.** 명료도 56.89로 VoxCPM2의 50.00보다 앞서고, 받아쓰기 상위 10퍼센트 오류도 0.289로 VoxCPM2의 0.435보다 꼬리가 짧습니다. 중국어는 상위 구간에서 갈리는 폭이 커서 중앙값만 보시면 판단을 그르칩니다.

⛔ **Zonos 중국어는 쓰지 마십시오.** 위 샘플에서 들으셨듯 문장이 아니라 같은 음절 반복이 나옵니다. 레포의 지원 언어 목록에는 중국어가 들어 있지만 실측 오류율이 1.0에서 6.9까지 나왔습니다. 지원 목록은 주장이지 측정이 아닙니다.


![tts-comparison-showcase 슬라이드 2](/assets/images/tts-comparison-showcase-slide-02.webp)

## 일본어

다섯 모델이 지원합니다.

> 会議は今日の午後、三階の会議室で始まります。

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-ja-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-ja-voxcpm2.mp3"></audio></p>
<p><strong>Zonos</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-ja-zonos2.mp3"></audio></p>
<p><strong>Supertonic-3</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-ja-supertonic-3.mp3"></audio></p>
<p><strong>Chatterbox-ML</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-ja-chatterbox-ml.mp3"></audio></p>

> 昨日の会議で決まった内容を反映して草案を修正しましたが、レビューがまだ終わっていないため、今日のリリースは難しそうです。

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-ja-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-ja-voxcpm2.mp3"></audio></p>
<p><strong>Zonos</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-ja-zonos2.mp3"></audio></p>
<p><strong>Supertonic-3</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-ja-supertonic-3.mp3"></audio></p>
<p><strong>Chatterbox-ML</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-ja-chatterbox-ml.mp3"></audio></p>

**Supertonic-3이 앞섭니다.** 자연성 종합 68.08로 가장 높고 명료도도 62.99로 가장 균형이 좋습니다. 받아쓰기 오류 중앙값도 0.008로 사실상 완벽합니다.

다만 어느 모델을 쓰시든 **검수를 예산에 넣으시는 편이 안전합니다.** 상위 10퍼센트 구간에서 Qwen3-TTS가 0.413, VoxCPM2가 0.438까지 올라갑니다. 네 언어 중 일본어가 일관되게 꼬리가 길었습니다.


## 숫자와 코드를 읽히면 이렇게 됩니다

언어별 받아쓰기 오류의 중앙값은 대부분 0에 가깝습니다. 그런데 상위 10퍼센트만 크게 튑니다.
오류가 고르게 퍼진 것이 아니라 **특정 범주에 몰려 있다**는 뜻입니다. 범주별로 쪼개 보면
평문과 의문문, 복합문은 거의 완벽하고 숫자와 전문용어에서만 무너집니다.

실제로 틀린 발화들입니다. 원문과 들리는 소리를 비교해 보시면 어디서 깨지는지 잡히실 겁니다.

> (technical) API 응답 코드가 503에서 200으로 정상화되었습니다.

<p><strong>Zonos · 오차 14.0968</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/b-ko-zonos2.mp3"></audio></p>

> (technical) モデル名は Qwen3-TTS-12Hz-1.7B で、ライセンスは Apache 2.0 です。

<p><strong>Zonos · 오차 0.973</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/b-ja-zonos2.mp3"></audio></p>

기사를 읽어주는 용도라면 무해합니다. 금액이나 일시, 제품 코드를 읽어야 하는 서비스라면 바로
이 두 범주가 사고 지점입니다. 다섯 모델이 같은 경향을 보였으니 특정 모델의 결함이 아니라 이
세대 TTS의 공통 성질에 가깝습니다. 숫자를 미리 한글로 풀어 넣는 얇은 전처리가 모델 교체보다
확실하고 훨씬 쌉니다.

![tts-comparison-showcase 슬라이드 3](/assets/images/tts-comparison-showcase-slide-03.webp)

## 감정을 지시하면 얼마나 달라지나

같은 문장을 여섯 감정으로 합성했습니다. 위가 감정 표현력이 높은 모델, 아래가 감정 조절 기능이
아예 없는 모델입니다.

#### Qwen3-TTS

> 그 사람이 방금 문을 열고 들어왔어요.

표현 폭과 적중률이 함께 유의한 유일한 모델입니다. 감정마다 톤이 달라지고, 그 방향이 요청과 맞습니다.

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

#### Zonos

> 그 사람이 방금 문을 열고 들어왔어요.

가장 크게 달라집니다. 그런데 분류기에 넣으면 요청한 감정으로 가지 않습니다.

<p><strong>중립</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-zonos2-neutral.mp3"></audio></p>
<p><strong>기쁨</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-zonos2-happy.mp3"></audio></p>
<p><strong>슬픔</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-zonos2-sad.mp3"></audio></p>
<p><strong>분노</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-zonos2-angry.mp3"></audio></p>
<p><strong>공포</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-zonos2-fear.mp3"></audio></p>
<p><strong>놀람</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-zonos2-surprise.mp3"></audio></p>

#### Chatterbox-ML

> 그 사람이 방금 문을 열고 들어왔어요.

Zonos와 같은 양상입니다. 소리는 확실히 흔들리는데 적중률은 우연 수준입니다.

<p><strong>중립</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-chatterbox-ml-neutral.mp3"></audio></p>
<p><strong>기쁨</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-chatterbox-ml-happy.mp3"></audio></p>
<p><strong>슬픔</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-chatterbox-ml-sad.mp3"></audio></p>
<p><strong>분노</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-chatterbox-ml-angry.mp3"></audio></p>
<p><strong>공포</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-chatterbox-ml-fear.mp3"></audio></p>
<p><strong>놀람</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-chatterbox-ml-surprise.mp3"></audio></p>

#### Kokoro-82M

> He just walked through the door a moment ago.

여섯 개가 같은 소리입니다. 감정 조절 기능이 없어서 지표의 바닥 역할을 합니다.

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

### 모델별 감정 표현력

들으신 인상을 숫자로 옮기면 이렇습니다. 두 가지를 따로 쟀습니다. **표현 폭**은 감정을 바꿨을 때
음높이와 세기, 쉼 같은 프로소디가 실제로 얼마나 달라지는지이고, **적중률**은 그렇게 만든 음성을
감정 분류기에 넣었을 때 요청한 감정으로 분류되는 비율입니다.

| 모델 | 표현 폭 | 바닥 대비 | 적중률 | 우연 대비 | 감정 조건을 주는 방법 |
|---|---|---|---|---|---|
| **Qwen3-TTS** | 0.408 | 16.9배 | **0.403** | **2.42배** | 지시문(instruct) 텍스트 |
| Zonos | **0.452** | 18.8배 | 0.167 | 1.00배 | 8차원 실수 벡터 직접 지정 |
| Chatterbox-ML | 0.445 | 18.4배 | 0.181 | 1.08배 | 과장도(exaggeration) 스칼라 |
| Supertonic-3 | 0.255 | 10.6배 | 0.222 | 1.33배 | 인라인 스타일 태그 |
| Kokoro-82M | 0.024 | 1.0배 | 0.167 | 1.00배 | **없음** |
| VoxCPM2 | 측정 불가 | | | | 참조 음성과 쌍으로만 |

**표에서 눈여겨보실 곳은 위 세 줄이 표현 폭에서 사실상 붙어 있다는 점입니다.** Zonos 0.452,
Chatterbox-ML 0.445, Qwen3-TTS 0.408로 셋 다 바닥의 열일곱 배 안팎입니다. 그런데 적중률로
가면 앞의 둘이 우연 수준으로 주저앉고 Qwen3-TTS만 남습니다.

혼동행렬을 보면 분명합니다. Zonos에게 분노를 요청하면 기쁨 3건, 역겨움 5건, 슬픔 2건으로
분류되고 분노는 0건입니다. 기쁨을 요청하면 중립 6건, 슬픔 3건으로 갑니다. 소리는 확실히
달라지는데 그 변화가 **요청한 감정 쪽으로 가지 않습니다.**

Chatterbox-ML이 같은 패턴을 따로 보여 준다는 점이 중요합니다. 설계가 전혀 다른 두 모델이
독립적으로 같은 자리에 떨어졌으니, 이건 한 모델의 결함이 아니라 **프로소디를 흔드는 일과 그
흔들림에 방향을 주는 일이 서로 다른 문제**라는 신호입니다. 앞쪽은 여러 모델이 이미 해내고
뒤쪽은 대부분 못 하고 있습니다.

Qwen3-TTS는 두 지표가 함께 유의합니다. 표현 폭 16.9배에 적중률 2.42배로, 소리도 달라지고 그
방향이 요청한 감정과 맞습니다. **감정 제어가 필요하시면 이 모델입니다.**

표현 폭만 보고 골랐다면 여섯 중 둘을 잘못 집었을 상황이라, 감정 축은 반드시 두 축으로
보셔야 합니다.

언어별로도 갈립니다. Qwen3-TTS는 네 언어에서 0.386에서 0.443 사이로 고르지만, Supertonic-3은
영어가 0.157로 유독 낮고 일본어가 0.354로 두 배 이상입니다. 같은 모델이라도 언어에 따라 감정
지시가 먹는 정도가 다르다는 뜻이라, 다국어 서비스라면 쓰실 언어에서 따로 확인하셔야 합니다.

VoxCPM2가 표에서 빠진 이유는 성능이 나빠서가 아닙니다. 이 모델은 감정을 **참조 음성과 쌍으로만**
받습니다. 참조 없이 감정만 지정하면 합성 자체가 실패합니다. 여기서 조용히 중립 음성으로 대체했다면
"감정 변화가 없는 모델"로 기록됐을 텐데, 실제로는 조건이 걸리지도 않은 것이라 정직하게 뺐습니다.

아래쪽 여섯 개가 사실상 같은 소리로 들리셨을 겁니다. 그 모델에는 감정 조절 기능이 없어서 여섯
번 모두 같은 입력이기 때문입니다. 그래서 이 모델이 **지표의 바닥** 역할을 합니다. 감정 분류기가
요청한 감정을 맞히는 비율이 0.167인데, 이 값은 여섯 감정을 균등하게 찍었을 때의 우연 확률과
정확히 같습니다.

바닥을 알고 나면 나머지가 다르게 읽힙니다. 표현 폭 상위 셋이 서로 붙어 있는데 그중 둘은
방향이 없습니다. **여섯 모델을 다 재고 나서 두 지표가 함께 유의한 모델은 Qwen3-TTS
하나뿐입니다.**

다만 절대 수준은 낮게 보셔야 합니다. 가장 잘한 모델조차 요청한 감정이 분류기까지 전달되는
비율이 절반을 넘지 못합니다. 감정 지시는 켜면 그 감정이 되는 스위치가 아니라 그쪽으로 조금
기울이는 손잡이에 가깝습니다.

## 숫자로 정리하면

![측정 결과]({{ site.url }}{{ site.baseurl }}/assets/images/tts-comparison-showcase-results.webp)
*왼쪽은 언어별 자연성, 오른쪽은 속도와 명료도의 관계입니다*

오른쪽 그림이 이 글의 요약입니다. 가로축 왼쪽일수록 빠르고 세로축 위쪽일수록 또렷한데, **왼쪽
위에 있는 모델이 없습니다.** 가장 빠른 VoxCPM2가 가장 아래에 있고, 가장 또렷한 Supertonic-3이
가장 오른쪽에 있습니다. 속도와 명료도는 함께 오지 않았습니다.

자연성은 TTSDS2로 쟀습니다. 합성 음성 집합과 실제 사람 음성 집합의 분포를 비교하는 방식이라
발화 하나하나를 채점하는 방식보다 언어를 덜 탑니다. 사람 음성 레퍼런스로는 구글 FLEURS의 검증
셋에서 언어당 120발화를 썼습니다.

![tts-comparison-showcase 슬라이드 4](/assets/images/tts-comparison-showcase-slide-04.webp)

## 이런 비교는 보통 어떻게 하나

같은 결과를 재현하시거나 직접 다른 모델을 재보실 때 참고하시라고, 이 분야에서 통용되는 측정
방식을 정리합니다.

**속도는 RTF로 잽니다.** 생성에 걸린 시간을 만들어진 음성 길이로 나눈 값입니다. 1보다 작으면
실시간보다 빠르다는 뜻이고, 스트리밍 서비스에서는 첫 소리가 나오기까지의 지연(TTFB)을 함께
보는 것이 보통입니다. 이번 측정은 문장 단위 일괄 생성 기준입니다.

**명료도는 받아쓰기로 잽니다.** 합성한 음성을 음성인식 모델에 넣어 원문과 비교합니다. 영어처럼
띄어쓰기가 뚜렷한 언어는 단어 오류율(WER), 한중일처럼 그렇지 않은 언어는 문자 오류율(CER)을
씁니다. 이 분야에서는 Whisper large-v3를 채점기로 쓰는 것이 사실상 관례라 저희도 그것을 따랐습니다.
⛔ 다만 중앙값만 보시면 안 됩니다. 이번에도 중앙값은 대부분 0인데 상위 10퍼센트에서 갈렸습니다.

**자연성은 두 갈래입니다.** 하나는 발화마다 점수를 매기는 MOS 예측기(UTMOS 계열)이고, 다른 하나는
합성 집합과 사람 음성 집합의 **분포를 통째로 비교**하는 방식(TTSDS2)입니다. 앞의 것은 대부분
영어로 학습돼 다른 언어에서는 보정되지 않은 값이 나옵니다. 다국어 비교에는 뒤의 것이 맞아서
이번 결론은 TTSDS2를 1차 지표로 삼았고, 종합 점수뿐 아니라 화자·운율·명료도 하위 축을 함께
봤습니다. 종합만 봤다면 이 글의 핵심을 놓쳤을 겁니다.

**감정은 아직 표준이 약합니다.** 널리 쓰이는 단일 지표가 없어서 두 가지를 조합했습니다. 프로소디
분산으로 표현 폭을 재고, 음성감정인식 모델로 적중률을 잽니다. **바닥부터 확보해야 합니다.**
감정 조절 기능이 없는 모델을 하나 같이 재면 "조건이 안 걸렸을 때의 값"이 나오고,
그 값 대비 배수로 읽어야 다른 숫자가 의미를 갖습니다. 이번에는 그 바닥이 0.024와 0.167이었습니다.

**공통 규칙 하나만 지키시면 됩니다.** 모든 모델에 같은 문장, 같은 시드, 같은 하드웨어를 쓰는
것입니다. 문장 셋이 다르면 같은 시드 번호라도 다른 실험이고, 이번에도 그 이유로 일부 측정을
비교 대상에서 제외했습니다.

## 언어별로 언제 무엇을 쓰나

용도까지 넣어 정리하면 이렇습니다.

| 용도 | 한국어 | 영어 | 중국어 | 일본어 |
|---|---|---|---|---|
| 실시간 대화 | VoxCPM2 + 숫자 전처리 | Kokoro-82M(CPU) | VoxCPM2 | VoxCPM2 |
| 감정이 있는 대화 | **Qwen3-TTS** | Qwen3-TTS | Qwen3-TTS | Qwen3-TTS |
| 안내·알림 음성 | Supertonic-3 | Kokoro-82M | Qwen3-TTS | Supertonic-3 |
| 오디오북·내레이션 | Supertonic-3 | 아무거나 | Qwen3-TTS | Supertonic-3 |
| 네 언어를 한 모델로 | Chatterbox-ML | Chatterbox-ML | Chatterbox-ML | Chatterbox-ML |
| 금액·코드 낭독 | 전처리 필수 | 전처리 필수 | 전처리 필수 | 전처리 + 검수 |

같은 언어라도 용도가 바뀌면 답이 바뀝니다. 실시간 대화는 지연이 품질보다 우선이라 RTF가 낮은
쪽으로 가고, 미리 만들어 두는 안내 음성은 반대로 시간을 더 써도 되니 명료도가 높은 쪽으로 갑니다.
감정이 필요한 순간에는 Qwen3-TTS가 유일한 선택입니다. 실시간보다 느리다는 대가가 있지만, 요청한
감정이 실제로 전달되는 모델이 이것뿐입니다.

마지막 줄에 Chatterbox-ML만 있는 이유는 이 모델이 네 언어를 하나로 덮으면서 RTF 0.675로
실시간을 지키는 유일한 조합이기 때문입니다. 다만 **중앙값이 좋다고 안심하시면 안 됩니다.**
오류율 중앙값은 한국어 0.068, 중국어 0.065로 준수한데, 상위 10퍼센트 구간에서 중국어가 0.844로
무너집니다. 열 문장 중 한 문장은 알아듣기 어려운 수준으로 나온다는 뜻이라, 사람이 안 보는
자동 파이프라인에 넣으실 거면 출력 검수를 함께 두셔야 합니다.

언어마다 최적이 다르므로 라우팅하는 얇은 층을 하나 두시면 영어 트래픽을 CPU로 빼내면서 각
언어에서 가장 나은 모델을 쓰실 수 있습니다. 운영 단순함이 더 중요하시면 Chatterbox-ML 한
모델로 덮고 검수를 붙이는 쪽이 관리 비용은 낮습니다.

## 알아두실 한계

FLEURS는 낭독체입니다. 문장을 또박또박 읽는 음성이라, 이번 자연성 점수는 **낭독에 가까운 음성을
얼마나 잘 만드는가**로 읽으셔야 정확합니다. 대화형 에이전트가 목표시라면 대화체 코퍼스로 다시
재보시는 편이 낫습니다.

CPU에서 돌린 두 모델의 전력 수치는 신뢰하지 마시기 바랍니다. 같은 설정을 세 번 반복하니 순증분
전력이 178퍼센트 흔들렸습니다. 공유 노드의 유휴 기준선 문제인데, 같은 실행의 속도는 7.9퍼센트만
움직였으니 속도 비교는 그대로 유효합니다.

마지막으로, 후보 열두 모델 중 다섯만 이 글에 실었습니다. 나머지 상당수는 기본 화자가 없어 참조
음성을 요구하는 복제형 모델이었습니다. 참조 음성을 주는 순간 재는 대상이 음성합성 품질에서 복제
충실도로 바뀌기 때문에 같은 표에 섞지 않았습니다. 그쪽은 따로 다루겠습니다.

## 참고 자료

비교에 쓴 모델과 지표의 정본 링크입니다.

- Qwen3-TTS: [Qwen/Qwen3-TTS-12Hz-1.7B-Base](https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base)
- VoxCPM2: [openbmb/VoxCPM2](https://huggingface.co/openbmb/VoxCPM2)
- Zonos: [Zyphra/ZONOS2](https://huggingface.co/Zyphra/ZONOS2)
- Supertonic-3: [Supertone/supertonic-3](https://huggingface.co/Supertone/supertonic-3)
- Kokoro-82M: [hexgrad/Kokoro-82M](https://huggingface.co/hexgrad/Kokoro-82M)
- Chatterbox: [ResembleAI/chatterbox](https://huggingface.co/ResembleAI/chatterbox)
- UTMOS: [mosmodels/utmos](https://huggingface.co/mosmodels/utmos)
- Whisper large-v3: [openai/whisper](https://github.com/openai/whisper)
- FLEURS: [google/fleurs](https://huggingface.co/datasets/google/fleurs)
- TTSDS2: [arXiv:2506.19441](https://arxiv.org/abs/2506.19441)

---

샘플 61개는 모두 이 측정에서 나온 실제 합성 결과이고, 후처리나 선별 없이 원장이 가리키는 파일을
그대로 변환한 것입니다.
