---
title: "브랜드 사운드를 GPU 한 장으로 만들었습니다: 곡당 0.007달러, 그리고 실행 스택이 만든 12.7배"
excerpt: "음악 생성 모델을 사내에서 서빙할지 고민 중이라면, 모델 선택보다 실행 스택을 먼저 보셔야 합니다. 같은 B200에 같은 가중치를 올리고 실행 경로만 바꿨더니 시간당 36곡이 463곡이 됐습니다. 곡당 원가는 0.007달러였고, 그 값으로 소닉 로고부터 광고 영상까지 브랜드 사운드 시스템 전체를 하루에 만들었습니다."
seo_title: "음악 생성 모델 서빙 실측: 12.7배 처리량 격차와 곡당 0.007달러"
seo_description: "MiniMax-Music3를 B200 한 장에서 재봤습니다. 레퍼런스 파이프라인 36곡/시간, 서빙 스택 463곡/시간. VRAM은 곡 길이와 무관하게 24.5GB로 고정이고, 유휴 전력만 239W입니다. 소닉 로고는 왜 생성 모델이 아니라 코드로 만들어야 하는지도 함께 다룹니다."
date: 2026-08-15
last_modified_at: 2026-08-15
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "music"
tags:
  - music-generation
  - inference-serving
  - sonic-branding
  - throughput-benchmark
  - power-measurement
  - multimodal
  - gpu-serving
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/sonic-branding-generative-music/"
audiobook: "https://drive.google.com/file/d/1tgEqND0M_NNXzWF3ht1L_77lGxCAzpRE/view"
audiobook_label: "▶ 5분 브리핑으로 듣기"
audiobook_note: "NotebookLM 오디오 개요 (AI 생성)"
---

음악 생성 모델을 사내에 올릴지 검토 중이시라면, 어떤 모델을 고르느냐보다 **그 모델을 어떻게
실행하느냐**를 먼저 보시는 편이 낫습니다. 같은 B200 한 장에 같은 가중치를 올리고 실행 경로만
바꿨더니 처리량이 **시간당 36곡에서 463곡으로 12.7배** 벌어졌습니다. 하드웨어도 모델도 그대로였고
달라진 것은 실행 스택뿐이었습니다.

그 결과 곡 하나의 원가가 **0.007달러**가 됐습니다. 소닉 브랜딩은 보통 여섯 자리 달러 단위
용역입니다. 곡당 1센트가 안 되면 브랜드 사운드 시스템 전체를 하루에 만들고, 마음에 안 들면
다시 만듭니다. 실제로 그렇게 만든 것들을 아래에서 들어보실 수 있습니다.

![브랜드 사운드를 GPU 한 장으로 만들었습니다: 곡당 0.007달러, 그리고 실행 스택이 만든 12.7배 개념을 형상화한 이미지](/assets/images/sonic-branding-generative-music-hero.webp)
*글의 핵심 개념을 형상화했습니다.*

## 무엇을 어디에 올렸나

MiniMax-Music3는 가사와 구조화된 캡션을 받아 32kHz 스테레오 완곡을 만드는 오픈 웨이트 모델입니다.
Global LLM 8B, Local LLM 0.6B, Flow Matching 2.4B, Flow-VAE 123M으로 이루어져 있고 가중치 전체가
57.35GB입니다.

가장 먼저 부딪힌 것은 모델을 클러스터에 가져다 놓는 일이었습니다. 같은 파일을 경로만 바꿔 재봤더니
이렇게 갈렸습니다.

| 경로 | 속도 | 57.35GB 환산 |
|---|---:|---:|
| GPU 파드에서 HuggingFace로 | 5.9 MB/s | 162분 |
| 사무실 맥에서 공식 다운로드 클라이언트로 | 2.1 MB/s | 7시간 |
| 사무실 맥에서 병렬 HTTP로 | 48.0 MB/s | 19.9분 |
| GPU 파드에서 내부 오브젝트 스토리지로 | 753~873 MB/s | 66~78초 |

내부망이 클러스터 외부 이그레스의 128배입니다. 그래서 적재 경로는 하나로 정해집니다. 사무실에서
받아 내부 스토리지에 올려두고, 이후 모든 잡은 내부망으로 당깁니다. 첫 잡에서 이미 본전을 뽑고,
그다음부터는 어떤 실험이든 75초면 모델이 손에 들어옵니다.

공식 다운로드 클라이언트가 병렬 curl보다 24배 느렸습니다. 이 클라이언트는
최근 Xet 전송 경로를 타는데, 같은 호스트에서 같은 파일을 단일 스트림 curl로 받아도 43.8 MB/s가
나왔습니다. 네트워크가 아니라 전송 계층이 병목이었습니다. 다만 이건 특정 시점의 관측이지 법칙이
아니므로, 큰 모델을 받기 전에는 한 번 재보시길 권합니다.

## 실행 스택이 만든 12.7배

모델 카드가 안내하는 레퍼런스 경로는 diffusers 파이프라인을 직접 호출하는 방식입니다. 이 경로로
60초짜리 곡 하나를 만드는 데 86초가 걸렸습니다. 실시간보다 느립니다.

그런데 측정값 하나가 눈에 걸렸습니다. **peak VRAM이 곡 길이와 무관하게 24.5GB로 고정**이었습니다.
30초 곡이든 240초 곡이든 같았습니다. B200은 191.5GB를 갖고 있으니 카드의 87%가 놀고 있었던
셈입니다. 메모리가 아니라 지연이 병목이라면 프로세스를 늘려 처리량을 곱할 수 있어야 합니다.

| 동시 실행 | 곡/시간 | 스케일링 | GPU util | 곡당 에너지 |
|---:|---:|---:|---:|---:|
| 1 | 36.4 | 1.00배 | 22.7% | 28,753 J |
| 2 | 72.5 | 1.99배 | 46.3% | 17,084 J |
| 4 | 109.9 | 3.02배 | 71.5% | 13,037 J |

2-way는 거의 완전한 선형이고 4-way에서 3.02배로 꺾입니다. 그런데 더 눈에 띄는 것은 마지막
열입니다. 곡당 에너지가 **2.2배 개선**됩니다. 왜 그런지는 전력을 재보고 나서야 알았습니다.

여기까지가 레퍼런스 경로를 최대한 짜낸 결과입니다. 그다음 같은 가중치를 서빙 엔진에 올렸습니다.
이 모델의 저장소에 들어 있는 자체 테스트 스크립트가 실은 OpenAI 호환 `/v1/audio/speech`
엔드포인트를 때리는 HTTP 클라이언트인데, 그것이 이 모델이 실제로 배포되는 모양을 말해주고
있었습니다.

| 동시 요청 | p50 지연 | 곡/시간 | RTF |
|---:|---:|---:|---:|
| 1 | 24.3s | 148.2 | 0.597 |
| 2 | 20.3s | 355.4 | 0.592 |
| 4 | 29.9s | 463.2 | 0.737 |

단일 요청 기준으로도 RTF가 0.597입니다. 실시간보다 빠릅니다. 레퍼런스 경로의 1.62와 비교하면
2.7배이고, 동시성까지 올리면 시간당 36곡과 463곡의 차이가 됩니다.

같은 카드, 같은 가중치입니다. 차이는 전부 실행 스택에서 나왔습니다. 새 멀티모달 모델을 검토할 때
"우리 GPU에서 도는가"까지만 확인하고 멈추면, 이 12.7배를 통째로 두고 가게 됩니다.

## 전력에서 배운 것

전력은 두 시점에서 쟀습니다. 모델을 올리기 전과 올린 뒤입니다.

| 시점 | 유휴 전력 | VRAM |
|---|---:|---:|
| 콜드, 모델 미로드 | 187 W | 4 MiB |
| 모델 상주 | 239 W | 23,484 MiB |

가중치가 VRAM에 앉아 있기만 해도 **52W**를 씁니다. 서빙 엔드포인트의 진짜 유휴는 187W가 아니라
239W이고, GPU를 통째로 임대하는 구조라면 이 52W도 우리가 냅니다.

이 숫자가 앞의 동시성 표를 설명합니다. 곡당 에너지가 2.2배 좋아진 것은 모델이 더 효율적으로 돈
게 아니라 **239W라는 유휴 바닥을 여러 곡이 나눠 졌기** 때문입니다. 처리량을 올리는 일은 비용
문제이기 이전에 이미 지불하고 있는 전력을 실제 일로 바꾸는 문제입니다.

전력을 인용할 때는 유휴를 언제 쟀는지가 함께 적혀 있어야 합니다. 모델 로드 직후에 재면 순증
전력이 실제보다 훨씬 작게 나오고, 그 값으로 계산한 곡당 에너지는 몇 배씩 틀립니다.

## 재현되지 않은 것

모델 카드는 최대 5분짜리 완곡을 만든다고 안내합니다. 저희 실행에서는 재현되지 않았습니다.

| 요청한 길이 | 실제 산출 |
|---:|---:|
| 30초 | 35.9초 |
| 60초 | 66.1초 |
| 120초 | 92.1초 |
| 240초 | 138.3초 |

짧은 요청은 오히려 넘치고, 길어질수록 미달합니다. 가장 길게 나온 것이 138.3초였습니다.
`audio_duration`은 지시가 아니라 힌트로 동작합니다. 모델 카드도 섹션 태그와 캡션이 "생성 제어이지
심볼릭 보장이 아니다"라고 적어두었는데, 그 문장의 실제 의미가 이 표입니다.

길이가 중요한 산출물이라면 이 모델 하나로는 안 되고, 렌더 단계에서 크로스페이드 루프로 채우는
파이프라인이 필요합니다. 뒤에 나오는 광고 영상이 정확히 그렇게 만들어졌습니다.

## 소닉 로고는 왜 생성 모델로 만들면 안 되는가

소닉 브랜딩 사례를 훑어보면 공통 구조가 보입니다. 넷플릭스의 "타둠", 인텔의 다섯 음, 마스터카드의
결제음은 모두 **2~5초짜리 니모닉 하나**를 최고 자산으로 두고 그 위에 편곡 시스템을 얹습니다.
넷플릭스가 그 소리를 만들 때 "스타트업처럼 테키한 소리"와 "게임기 같은 소리"를 의도적으로
거부했다는 기록도 참고할 만합니다.

그런데 니모닉은 생성 모델로 만들면 안 됩니다. 이유는 단순합니다. **로고는 매번 똑같아야 인식이
쌓입니다.** 광고 끝, 제품 부팅, 행사 오프닝에서 같은 세 음이 같은 음색으로 나야 합니다. 생성
모델은 seed를 고정해도 버전이 바뀌면 달라지고, 무엇보다 "정확히 이 주파수"를 요구할 수 없습니다.

그래서 분업을 이렇게 나눴습니다. **니모닉은 코드가 소유하고, 편곡은 모델이 소유합니다.**

모티프는 B♭3, F4, B♭4입니다. 근음과 5도와 옥타브, 배음렬 그대로입니다. 물리적으로 가장 기본적인
세 음을 쌓아 올린 것이라 인프라 회사의 스택이 그대로 소리가 됩니다. 음색은 나무 말렛으로 시작해
정현파로 번지게 했습니다. 사람이 하던 일이 정확한 자동화로 넘어가는 소리로 잡았습니다.

<p><audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/logo-full.mp3"></audio></p>

이 파일은 numpy가 만듭니다. 배음의 비정수배 비율, 어택 길이, 절차 생성 잔향까지 전부 코드에
숫자로 적혀 있고, 다시 돌리면 바이트가 같습니다.

## 같은 세 음, 일곱 개의 편곡

저희 브랜드 메시지는 "One Paxis. Many Workflows. Any Cloud."입니다. 하나의 에이전트 플랫폼이
업무마다 다르게 흐른다는 뜻인데, 소닉 아키텍처도 같은 모양이어야 한다고 봤습니다.

그래서 일곱 제품이 **전부 같은 세 음을 쓰고 배음과 잔향과 바닥만 다릅니다.** 연달아 들어보면 같은
곡의 다른 얼굴로 들립니다.

<p>Paxis, 에이전트 자동화. 기준이 되는 진술입니다.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/logo-paxis.mp3"></audio></p>

<p>Metis, 추론. 밝고 빠르게 떨어집니다. 응답이 즉시 온다는 느낌입니다.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/logo-metis.mp3"></audio></p>

<p>Maxis, 학습. 어둡고 길게 쌓입니다. 시간이 걸리는 일입니다.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/logo-maxis.mp3"></audio></p>

<p>Velox, 베어메탈. 금속성이고 잔향이 거의 없습니다. 층이 없는 직결입니다.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/logo-velox.mp3"></audio></p>

<p>Aegis, 온프렘. 낮고 단단합니다. 닫힌 공간 안에 있습니다.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/logo-aegis.mp3"></audio></p>

## 모델이 만든 부분

편곡은 모델에게 맡겼습니다. 캡션에 모티프를 말로 지시했습니다. "근음과 5도와 옥타브 세 음을
마림바가 진술하고 곡 전체에서 반복한다." 나머지는 용도별로 템포, 조성, 편성, 감정 진행을 적었습니다.

<p>메인 광고 베드. 96 BPM, 비어 있게 시작해 3분의 2 지점에서 넓게 도착합니다.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/brand-ad-main.mp3"></audio></p>

<p>Metis 제품 영상. 112 BPM, 빌드 없이 첫 마디부터 즉시 시작합니다.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/brand-product-metis.mp3"></audio></p>

<p>Maxis 제품 영상. 88 BPM, 거의 빈 채로 시작해 한 겹씩 늘어납니다.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/brand-product-maxis.mp3"></audio></p>

<p>Aegis 제품 영상. 84 BPM, 고음이 거의 없고 낮게 단단합니다.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/brand-product-aegis.mp3"></audio></p>

캡션에 실존 아티스트의 이름은 한 번도 쓰지 않았습니다. 장르와 BPM과 악기와 질감만 적었습니다.
이건 취향 문제가 아니라 실무 문제입니다. 스포티파이에서 1,300만 스트림을 기록했던 AI 생성곡이
특정 가수의 목소리와 유사하다는 이유로 전 플랫폼에서 삭제된 사례가 있습니다. 목소리를 흉내 내는
순간 그 자산은 언제든 사라질 수 있는 자산이 됩니다.

## 광고 영상까지

음악만 만들고 끝내면 광고가 아닙니다. 위 자산으로 54초짜리 브랜드 영상을 만들었습니다.

<video controls preload="metadata" playsinline style="width:100%;border-radius:12px">
  <source src="/assets/video/posts/sonic-branding-generative-music/brand-ad.mp4" type="video/mp4">
</video>

여는 소리와 닫는 소리가 코드로 만든 소닉 로고이고, 그 사이가 모델이 만든 음악입니다. 두 층이
크로스페이드로 붙어 있습니다. 화면의 텍스트와 도형과 타이밍은 파이썬이 프레임으로 굽고 ffmpeg이
합쳤습니다. 영상 편집 도구는 쓰지 않았습니다.

앞서 말한 길이 문제가 여기서 드러납니다. 60초를 요청한 광고 베드가 22초로 나왔기 때문에, 빌더가
1초 크로스페이드로 루프를 이어 47초를 채웁니다. 모델의 한계를 렌더 단계가 흡수하는 구조입니다.

보컬이 들어간 완곡도 됩니다. 브랜드용은 전부 인스트루멘탈이지만 모델 자체는 가사가 있는 곡을
만듭니다.

<p>한국어 발라드. 84 BPM.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/hello-ko-60s.mp3"></audio></p>

<p>트로트와 멤피스 펑크를 섞은 것. 138 BPM.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/viral-02-trot-phonk.mp3"></audio></p>

## ThakiCloud 관점

이 실측이 저희 제품에 어떻게 붙는지 적어두겠습니다.

**Metis에게 음악은 새 축이 아니라 같은 축입니다.** 토큰 팩토리의 경제성은 지금까지 텍스트 추론
기준으로 이야기해 왔는데, 이번 측정은 그 구조가 멀티모달에도 그대로 성립한다는 것을 보여줍니다.
같은 GPU에서 실행 스택을 바꿔 12.7배를 얻는 일, 유휴 전력 바닥을 동시성으로 상각하는 일,
peak VRAM 대비 남는 용량을 처리량으로 환산하는 일은 LLM 서빙에서 하던 것과 정확히 같은 작업입니다.
음악 생성 엔드포인트를 카탈로그에 올리는 것은 새 인프라를 짓는 일이 아니라 이미 있는 인프라에
모델 하나를 더 태우는 일입니다.

**적재 경로는 플랫폼이 이미 소유하고 있어야 하는 자산입니다.** 클러스터 외부 이그레스가 5.9MB/s인
환경에서 57GB 모델을 매번 받으면 실험 하나에 162분이 붙습니다. 내부 레지스트리에 한 번 올려두면
75초입니다. 이건 특정 모델의 이야기가 아니라 새 모델이 나올 때마다 반복되는 비용이고, 자체 GPU를
운영하는 조직이라면 이 경로를 도구로 갖고 있어야 합니다. 저희는 병렬 HTTP 페처와 멀티파트 업로더,
카탈로그 등록까지를 스크립트로 고정해 두었습니다.

**Paxis 관점에서는 이 전체가 하나의 워크플로입니다.** 모델 적재, 프리플라이트 게이트, 생성, 산출물
회수, 렌더, 배포 전 검증까지가 사람이 붙어 있어야 하는 단계로 흩어져 있으면 브랜드 사운드 하나
만드는 데 며칠이 걸립니다. 이번 작업에서 사람이 판단한 것은 모티프를 어떤 세 음으로 할지와 어떤
결과물을 내보낼지 두 가지였고 나머지는 파이프라인이 돌았습니다. 업무 자동화를 파는 회사라면 자기
브랜드 자산부터 그렇게 만들어 보는 편이 설득력이 있다고 봅니다.

## 남는 것

새 멀티모달 모델을 검토할 때 "도는가"에서 멈추지 마십시오. 이번 경우 실행 스택만으로 12.7배가
갈렸고, 그 차이는 모델 카드 어디에도 적혀 있지 않습니다.

전력을 인용하실 때는 유휴를 언제 쟀는지 함께 적으십시오. 가중치 상주만으로 52W가 나가고, 그 바닥을
어떻게 상각하느냐가 곡당 에너지를 2.2배까지 바꿉니다.

그리고 정확해야 하는 것과 풍부해야 하는 것을 나누십시오. 로고의 세 음은 코드가, 편곡과 음색은
모델이 맡습니다. 생성 모델을 어디에 쓰지 **않을지** 정하는 것이 어디에 쓸지 정하는 것만큼
중요했습니다.

이 글의 음악은 전부 오픈 웨이트 모델로 만들었고 실존 아티스트의 목소리나 스타일을 모사하지
않았습니다. 상업 배포에는 별도의 라이선스와 공시 검토가 필요하며 아직 어디에도 배포하지
않았습니다. 위 수치는 NVIDIA B200 한 장에서 bf16으로 측정한 실측값입니다.

## 참고 자료

- MiniMax-Music3 모델: [MiniMaxAI/MiniMax-Music3 (Hugging Face)](https://huggingface.co/MiniMaxAI/MiniMax-Music3)
- Flow Matching 아키텍처: [Flow Matching for Generative Modeling (arXiv)](https://arxiv.org/abs/2210.02747)
- 레퍼런스 파이프라인 (diffusers): [Diffusers (Hugging Face)](https://huggingface.co/docs/diffusers)
- Xet 전송 경로: [Xet: our Storage Backend (Hugging Face)](https://huggingface.co/docs/hub/en/xet)

## 관련 슬라이드

본문 내용을 NotebookLM(`architectural_portfolio` 스타일)으로 요약한 슬라이드입니다.

![sonic-branding-generative-music 슬라이드 1](/assets/images/sonic-branding-generative-music-slide-01.png)

![sonic-branding-generative-music 슬라이드 2](/assets/images/sonic-branding-generative-music-slide-02.png)

![sonic-branding-generative-music 슬라이드 3](/assets/images/sonic-branding-generative-music-slide-03.png)

![sonic-branding-generative-music 슬라이드 4](/assets/images/sonic-branding-generative-music-slide-04.png)

