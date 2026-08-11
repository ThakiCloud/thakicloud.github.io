---
title: "OpenAI 실시간 음성 API를 한 줄로 갈아타기: 직접 돌리는 오픈 음성 스택 hugging-voice"
excerpt: "허깅페이스가 공개한 hugging-voice와 그 엔진인 speech-to-speech는 VAD에서 STT, LLM, TTS까지 이어지는 실시간 음성 파이프라인을 OpenAI Realtime 호환 WebSocket으로 감쌌습니다. 클라이언트의 base URL 한 줄만 바꾸면 자체 인프라로 옮겨올 수 있다는 이 접근을, 서빙 관점에서 뜯어봤습니다."
date: 2026-07-21
tags:
  - speech-to-speech
  - 실시간음성
  - VoiceAI
  - OpenAIRealtime
  - STT
  - TTS
  - LLM서빙
  - LLMOps
  - 온프렘
  - self-hosting
author_profile: true
toc: true
toc_label: 실시간 음성 스택 해부
lang: ko
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/hugging-voice-open-realtime-voice-self-hosted/"
published: false
audiobook: /assets/audio/posts/hugging-voice-open-realtime-voice-self-hosted/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

![직접 돌리는 오픈 실시간 음성 파이프라인]({{ '/assets/images/hugging-voice-open-realtime-voice-self-hosted-hero.png' | relative_url }})

이 글은 음성 에이전트를 붙이려다 OpenAI Realtime API의 종속과 비용 앞에서 멈칫한 엔지니어, 그리고 대화형 음성 기능을 자체 인프라에서 서빙할 수 있을지 저울질하는 인프라 담당자를 위해 썼습니다. 결론부터 말하면, 허깅페이스가 공개한 데모 [hugging-voice](https://huggingface.co/spaces/HuggingFaceM4/hugging-voice)와 그 밑에서 돌아가는 라이브러리 [speech-to-speech](https://github.com/huggingface/speech-to-speech)의 설계는 단순하면서도 실용적입니다. 실시간 음성을 위한 네 단계 파이프라인을 그대로 오픈소스로 열어 두되, 바깥쪽은 OpenAI Realtime과 똑같은 인터페이스로 감쌌습니다. 그래서 이미 OpenAI 실시간 클라이언트로 짜 둔 코드가 있다면, 서버를 가리키는 주소 한 줄만 바꿔 자체 스택으로 옮겨올 수 있습니다. 다만 성능에 관한 수치는 프로젝트가 공개한 범위에서만 인용하고, 저희가 직접 벤치마크한 값이 아님을 먼저 분명히 해 둡니다.

## 개요

지난 1년 사이 대화형 음성은 텍스트 챗봇의 곁가지가 아니라 독립된 제품군이 됐습니다. 사용자는 말을 걸고, 답이 사람과 대화하듯 즉시 돌아오기를 기대합니다. 문제는 이 기대치를 맞추는 상용 경로가 사실상 OpenAI Realtime API 같은 소수의 폐쇄형 서비스로 수렴해 왔다는 점입니다. 편하긴 하지만 음성 트래픽은 토큰이 아니라 초 단위로 과금되기 쉽고, 데이터가 외부로 나가며, 모델과 목소리 선택지가 공급자에 묶입니다.

hugging-voice는 이 흐름에 대한 반례로 등장했습니다. 스페이스의 부제부터가 "직접 돌릴 수 있는 오픈 실시간 음성(An Open Realtime Voice You Can Actually Run Yourself)"입니다. 마이크로 들어온 목소리를 텍스트로 바꾸고, 언어 모델에 보내고, 답을 다시 음성으로 되돌려 주는 이 왕복 전체를, 구성 요소 하나하나를 교체할 수 있는 오픈 파이프라인으로 열어 둔 것이 핵심입니다. 저희처럼 온프렘과 소버린 환경에서 모델을 서빙하는 입장에서는, "실시간 음성을 자체 클러스터에서 돌릴 수 있는가"라는 질문에 대한 구체적인 참조 구현이 생긴 셈입니다.

## hugging-voice와 speech-to-speech는 무엇인가

용어부터 정리하면, hugging-voice는 웹에서 바로 말을 걸어 볼 수 있는 데모 스페이스이고, 그 안에서 실제로 음성을 처리하는 엔진이 speech-to-speech 라이브러리입니다. 라이브러리는 실시간 음성 에이전트를 네 단계로 나눕니다. 음성 구간 감지(VAD), 음성 인식(STT), 언어 모델(LLM), 음성 합성(TTS)입니다. 각 단계는 별도 스레드에서 돌고 큐로 연결되어, 앞 단계의 출력이 스트리밍으로 다음 단계에 흘러 들어갑니다. 사용자가 말을 마치기도 전에 부분 전사가 나오고, 모델이 문장을 완성하기 전에 앞부분부터 음성 합성이 시작되는 구조라 체감 지연을 줄일 수 있습니다.

<div class="mermaid">
flowchart TB
    A["마이크 입력<br/>실시간 오디오 스트림"] --> B["VAD 발화 구간 감지<br/>Silero VAD v5"]
    B --> C["STT 음성 인식<br/>Parakeet TDT · Whisper 등"]
    C --> D["LLM 응답 생성<br/>OpenAI 호환 API · vLLM · llama.cpp"]
    D --> E["TTS 음성 합성<br/>Qwen3-TTS · Kokoro 등"]
    E --> F["스피커 출력<br/>스트리밍 재생"]
    G["OpenAI Realtime 호환<br/>WebSocket 서버"] -.- B
    G -.- C
    G -.- D
    G -.- E
</div>

이 그림에서 오른쪽의 WebSocket 서버가 이 프로젝트의 진짜 무기입니다. 네 단계를 잘 붙였다는 것만으로는 새롭지 않습니다. speech-to-speech가 다른 점은, 이 파이프라인 전체를 OpenAI Realtime 프로토콜과 호환되는 WebSocket 엔드포인트로 감쌌다는 데 있습니다. 덕분에 기존 OpenAI 실시간 클라이언트가 이 서버를 마치 OpenAI인 것처럼 붙어서 쓸 수 있습니다. 참고로 이 스택은 실험용 장난감이 아니라, 허깅페이스가 판매하는 Reachy Mini 로봇의 실시간 음성 인프라를 실제로 구동하고 있습니다.

## 한 줄로 갈아타기

프로젝트가 스스로 "한 줄 이전(one-line migration)"이라고 부르는 대목이 여기입니다. OpenAI Realtime을 쓰던 클라이언트에서 바꿔야 하는 것은 접속 주소뿐입니다. 아래는 프로젝트 문서가 제시하는 파이썬 클라이언트 예시입니다.

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:8765/v1",
    websocket_base_url="ws://localhost:8765/v1",
    api_key="not-needed",
)

with client.realtime.connect(model="local") as conn:
    conn.send({
        "type": "session.update",
        "session": {
            "type": "realtime",
            "instructions": "You are a helpful assistant.",
            "audio": {
                "input": {
                    "turn_detection": {
                        "type": "server_vad",
                        "interrupt_response": True,
                    }
                }
            },
        }
    })

    for event in conn:
        print(event.type)
```

눈여겨볼 부분은 `base_url`과 `websocket_base_url`이 로컬 서버를 가리키고, `api_key`가 사실상 필요 없다는 점입니다. `session.update`로 넘기는 지시문, 서버 측 VAD 기반 턴 감지, 응답 중 끼어들기 같은 옵션은 OpenAI Realtime과 같은 스키마를 그대로 따릅니다. 즉 애플리케이션 코드는 거의 손대지 않고, 백엔드만 외부 API에서 자체 서버로 옮겨오는 구조입니다. 벤더 종속을 걱정하는 팀에게는 이 인터페이스 호환성 자체가 가장 큰 실용적 가치입니다.

## 설치와 실행

서버를 띄우는 경로도 간결합니다. 기본 설치는 표준 실시간 경로를 한 번에 덮습니다.

```bash
pip install speech-to-speech
```

기본 구성은 STT로 Parakeet TDT, LLM으로 OpenAI 호환 API, TTS로 Qwen3-TTS를 씁니다. 특정 백엔드가 필요하면 추가 익스트라로 설치합니다.

```bash
pip install "speech-to-speech[kokoro]"
pip install "speech-to-speech[faster-whisper]"
```

서버 실행은 다음과 같습니다. 이 명령은 OpenAI Realtime 호환 서버를 로컬 WebSocket으로 띄웁니다.

```bash
export OPENAI_API_KEY=...
speech-to-speech
```

여기서 흥미로운 지점은, LLM 단계를 완전히 로컬로 돌릴 수 있다는 것입니다. 아래는 llama.cpp로 Gemma 4 계열 모델을 띄우고, speech-to-speech가 그 로컬 엔드포인트를 바라보게 하는 예시입니다.

```bash
llama-server -hf ggml-org/gemma-4-E4B-it-GGUF -np 2 -c 65536

speech-to-speech \
    --model_name "ggml-org/gemma-4-E4B-it-GGUF" \
    --responses_api_base_url "http://127.0.0.1:8080/v1" \
    --responses_api_api_key ""
```

애플 실리콘 맥이라면 최적화 옵션을 켜고 mlx 모델을 붙일 수 있고, 반대로 로컬 GPU가 부족하면 허깅페이스 인퍼런스 프로바이더를 LLM 백엔드로 지정할 수도 있습니다.

```bash
speech-to-speech \
    --local_mac_optimal_settings \
    --model_name "mlx-community/Qwen3-4B-Instruct-2507-bf16"
```

같은 파이프라인을 로컬 완전 실행부터 클라우드 추론 위임까지, 플래그 몇 개로 오갈 수 있다는 점이 설계의 미덕입니다.

## 모듈 교체: STT, LLM, TTS 백엔드

이 프로젝트가 단순한 데모를 넘어 참조 아키텍처로 읽히는 이유는 각 단계의 백엔드를 갈아 끼울 수 있기 때문입니다. 정리하면 다음과 같습니다.

| 단계 | 기본 백엔드 | 교체 가능한 대안 |
|---|---|---|
| VAD | Silero VAD v5 | 내장 전용 |
| STT | Parakeet TDT | Whisper, Faster Whisper, Paraformer |
| LLM | OpenAI 호환 API | Transformers, mlx-lm, vLLM, llama.cpp |
| TTS | Qwen3-TTS | Kokoro, Pocket TTS, ChatTTS, MMS |

실행 모드도 네 가지입니다. 기본값인 realtime은 OpenAI Realtime 프로토콜의 WebSocket이고, local은 마이크와 스피커에 직접 붙는 모드, websocket과 socket은 각각 WebSocket과 TCP로 원시 PCM 오디오를 주고받는 저수준 모드입니다. 언어도 지정하거나 자동 감지에 맡길 수 있습니다. 이렇게 STT 정확도, LLM 품질과 비용, TTS 음색과 지연을 각자의 요구에 맞춰 조합할 수 있다는 점이, 폐쇄형 API가 주지 못하는 자유도입니다.

## 지연시간, 그리고 실제 사례

음성 에이전트에서 지연은 정확도만큼이나 중요한 변수입니다. 사람은 응답이 몇백 밀리초만 늦어도 대화가 끊긴다고 느낍니다. 허깅페이스가 세레브라스(Cerebras)와 함께 공개한 [실시간 음성 데모](https://huggingface.co/blog/cerebras-gemma4-voice-ai)는 이 지연 문제를 정면으로 겨냥합니다. 구성은 STT에 엔비디아 Parakeet, 언어 모델에 세레브라스 추론 위에서 도는 구글 딥마인드 Gemma 4, TTS에 알리바바 Qwen3-TTS를 쓰는 조합입니다. 세레브라스의 초고속 추론으로 LLM 단계의 응답 시간을 끌어내려, 대화가 사람과의 대화만큼 자연스럽게 흐르도록 만드는 것이 목표입니다. 다만 이 글이 확인한 범위에서 구체적인 밀리초 단위 수치는 공개되지 않았으므로, 정량 비교는 유보합니다.

프로덕션 근거도 있습니다. 이 스택은 앞서 언급한 Reachy Mini 로봇을 구동하며, 허깅페이스는 이미 9,000대 이상의 로봇이 현장에 배포됐다고 밝히고 있습니다. 임베디드 환경에서 반응 속도가 곧 "상호작용이 살아 있다는 느낌"을 좌우한다는 것이, 이 프로젝트가 지연에 집착하는 이유입니다. 저희 블로그에서 음성 에이전트의 지연 예산을 GPU 서빙 관점에서 따로 다룬 적이 있으니, 파이프라인 각 단계의 지연을 어떻게 배분할지 고민한다면 [음성 에이전트 지연 예산과 GPU 서빙](/ko/llmops/voice-agent-latency-budget-gpu-serving/) 글을 함께 보시길 권합니다.

## ThakiCloud 제품 적용 시사점

이 파이프라인은 저희 두 제품 모두와 자연스럽게 맞물립니다.

ai-platform 렌즈에서 보면, speech-to-speech의 LLM 단계는 결국 OpenAI 호환 엔드포인트를 소비할 뿐이므로, 그 자리에 ThakiCloud의 vLLM 서빙을 그대로 꽂을 수 있습니다. STT와 TTS 모델은 각각 GPU를 점유하는 별도 워크로드가 되는데, 저희는 Kueue로 GPU를 큐잉하고 멀티테넌트로 격리해 이런 이종 추론 워크로드를 한 클러스터에 함께 태우는 데 강점이 있습니다. 음성 트래픽은 초 단위로 과금이 불어나기 쉬워 자체 서빙의 단가 경쟁력이 특히 크게 작동하고, 데이터가 외부로 나가지 않아야 하는 온프렘과 소버린 요구에도 이 오픈 스택은 그대로 부합합니다. 폐쇄형 음성 API가 부담스러운 고객에게, "같은 인터페이스로 자체 클러스터에서 돌린다"는 선택지를 제시할 수 있는 것입니다.

Paxis 렌즈에서 보면, 음성은 에이전트에 붙는 새로운 입출력 채널입니다. Paxis는 ai-platform 위에서 도는 Agent-Native Cloud 제어 평면으로 Skills, Tools, Policies, Audit Logs를 일급 리소스로 다루는데, speech-to-speech의 OpenAI Realtime 호환 인터페이스는 이 음성 채널을 기존 에이전트 오케스트레이션에 얹기 쉽게 만듭니다. 사용자가 말로 지시하면 그 발화가 곧 에이전트의 입력이 되고, 스킬 실행 결과가 음성으로 되돌아오는 흐름을, 정책 게이트와 감사 로그를 통과시키면서 구성할 수 있습니다. 저비용 자체 서빙(ai-platform)이 음성 에이전트의 경제성을 만들고, 그 위에서 Agent-Native 제어 평면(Paxis)이 음성이라는 채널을 안전하게 다루는 그림입니다.

## 마무리

hugging-voice가 던지는 메시지는 명확합니다. 실시간 음성은 더 이상 소수 공급자의 폐쇄형 API에만 기댈 필요가 없고, 필요하면 인터페이스는 그대로 둔 채 백엔드만 자체 인프라로 옮겨올 수 있다는 것입니다. VAD에서 TTS까지 각 단계를 골라 끼우고, 클라이언트는 주소 한 줄만 바꾸는 이 설계는, 자체 서빙을 검토하는 팀에게 진입 비용을 크게 낮춰 줍니다. 직접 확인하고 싶다면 [데모 스페이스](https://huggingface.co/spaces/HuggingFaceM4/hugging-voice)에서 바로 말을 걸어 보거나, [GitHub 저장소](https://github.com/huggingface/speech-to-speech)에서 `pip install speech-to-speech`로 시작하시면 됩니다.

## 관련 슬라이드

본문 내용을 NotebookLM(`neon_venture` 스타일)으로 요약한 슬라이드입니다.

![hugging-voice-open-realtime-voice-self-hosted 슬라이드 1](/assets/images/hugging-voice-open-realtime-voice-self-hosted-slide-01.png)

![hugging-voice-open-realtime-voice-self-hosted 슬라이드 2](/assets/images/hugging-voice-open-realtime-voice-self-hosted-slide-02.png)

![hugging-voice-open-realtime-voice-self-hosted 슬라이드 3](/assets/images/hugging-voice-open-realtime-voice-self-hosted-slide-03.png)

![hugging-voice-open-realtime-voice-self-hosted 슬라이드 4](/assets/images/hugging-voice-open-realtime-voice-self-hosted-slide-04.png)

