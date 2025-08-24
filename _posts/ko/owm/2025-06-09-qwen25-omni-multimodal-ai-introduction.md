---
title: "Qwen2.5-Omni: 알리바바 클라우드의 차세대 멀티모달 AI 모델"
date: 2025-06-09
categories: 
  - owm
  - ai
tags: 
  - qwen
  - multimodal
  - ai
  - alibaba
  - speech
  - vision
  - nlp
author_profile: true
toc: true
toc_label: "목차"
---

알리바바 클라우드의 Qwen 팀이 최근 발표한 Qwen2.5-Omni는 텍스트, 오디오, 비전, 비디오를 통합적으로 처리할 수 있는 엔드-투-엔드 멀티모달 AI 모델입니다. 이 모델은 실시간 음성 생성 기능까지 지원하여 더욱 자연스러운 인간-AI 상호작용을 가능하게 합니다.

## 주요 특징

### 멀티모달 통합 처리

Qwen2.5-Omni는 다양한 모달리티를 단일 모델로 처리할 수 있는 능력을 갖추고 있습니다:

- **텍스트**: 자연어 이해 및 생성
- **오디오**: 음성 인식 및 음성 합성
- **비전**: 이미지 분석 및 이해
- **비디오**: 동영상 콘텐츠 분석

### 실시간 음성 생성

이 모델의 가장 주목할 만한 특징 중 하나는 실시간 음성 생성 기능입니다. 사용자와의 대화에서 텍스트 응답과 동시에 자연스러운 음성으로 답변을 제공할 수 있습니다.

## 모델 구성

### 모델 크기

Qwen2.5-Omni는 두 가지 크기로 제공됩니다:

- **7B 모델**: 70억 파라미터로 높은 성능을 제공
- **3B 모델**: 30억 파라미터로 효율적인 배포가 가능

### 아키텍처

모델은 다음과 같은 구성 요소로 이루어져 있습니다:

- **Thinker**: 텍스트 이해 및 생성을 담당
- **Talker**: 음성 생성을 담당
- **Code2Wav**: 음성 코드를 실제 오디오로 변환

## 배포 옵션

### 웹 데모

가장 간단한 사용 방법은 웹 데모를 통한 것입니다:

```bash
# 기본 사용법 (7B 모델)
python web_demo.py

# 3B 모델 사용
python web_demo.py -c Qwen/Qwen2.5-Omni-3B

# FlashAttention-2 활성화
python web_demo.py --flash-attn2
```

### vLLM을 통한 배포

고성능 추론을 위해 vLLM을 사용할 수 있습니다:

```bash
# 단일 GPU 환경
vllm serve /path/to/Qwen2.5-Omni-7B/ --port 8000 --host 127.0.0.1 --dtype bfloat16

# 멀티 GPU 환경 (4개 GPU 예시)
vllm serve /path/to/Qwen2.5-Omni-7B/ --port 8000 --host 127.0.0.1 --dtype bfloat16 -tp 4
```

### Docker 배포

환경 설정을 단순화하기 위해 Docker 이미지가 제공됩니다:

```bash
docker run --gpus all --ipc=host --network=host --rm --name qwen2.5-omni -it qwenllm/qwen-omni:2.5-cu121 bash
```

## 모바일 및 엣지 배포

### MNN 지원

Qwen2.5-Omni는 MNN 프레임워크를 통해 모바일 및 엣지 디바이스에서도 실행할 수 있습니다. 다양한 모바일 SoC에서의 성능 벤치마크가 제공됩니다:

| 플랫폼 | 모델 크기 | 메모리 사용량 | Thinker 디코드 속도 |
|--------|-----------|---------------|-------------------|
| Snapdragon 8 Gen 1 | 7B | 5.8GB | 8.35 tok/s |
| Snapdragon 8 Elite | 7B | 5.8GB | 11.52 tok/s |
| Snapdragon 8 Gen 1 | 3B | 3.6GB | 15.84 tok/s |
| Snapdragon 8 Elite | 3B | 3.6GB | 23.31 tok/s |

## API 사용 예시

REST API를 통해 모델을 호출할 수 있습니다:

```bash
curl http://localhost:8000/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d '{
    "messages": [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": [
        {"type": "image_url", "image_url": {"url": "https://example.com/image.png"}},
        {"type": "audio_url", "audio_url": {"url": "https://example.com/audio.wav"}},
        {"type": "text", "text": "이미지와 오디오를 분석해주세요."}
    ]}
    ]
    }'
```

## 기술적 혁신

### 엔드-투-엔드 학습

Qwen2.5-Omni는 각 모달리티를 개별적으로 처리하는 것이 아니라, 모든 모달리티를 통합적으로 학습한 엔드-투-엔드 모델입니다. 이는 모달리티 간의 상호작용을 더 잘 이해하고 활용할 수 있게 합니다.

### 실시간 상호작용

기존의 멀티모달 모델들이 주로 배치 처리에 초점을 맞췄다면, Qwen2.5-Omni는 실시간 음성 생성을 통해 더욱 자연스러운 대화형 AI 경험을 제공합니다.

## 활용 분야

### 고객 서비스

음성과 텍스트를 동시에 처리할 수 있어 고객 서비스 챗봇이나 음성 어시스턴트로 활용할 수 있습니다.

### 교육 및 학습

멀티모달 입력을 통해 더욱 풍부한 교육 콘텐츠를 제공하고, 음성 피드백을 통해 학습자와 상호작용할 수 있습니다.

### 콘텐츠 생성

텍스트, 이미지, 오디오를 통합적으로 분석하여 다양한 형태의 콘텐츠를 생성할 수 있습니다.

## 라이선스 및 접근성

Qwen2.5-Omni는 Apache-2.0 라이선스 하에 오픈소스로 공개되어 있어 상업적 사용이 가능합니다. GitHub에서 소스 코드를 확인할 수 있으며, Hugging Face와 ModelScope에서 사전 훈련된 모델을 다운로드할 수 있습니다.

## 결론

Qwen2.5-Omni는 멀티모달 AI 분야에서 중요한 진전을 보여주는 모델입니다. 특히 실시간 음성 생성 기능과 엔드-투-엔드 학습 방식은 기존 모델들과 차별화되는 주요 특징입니다. 오픈소스로 공개되어 있어 연구자와 개발자들이 쉽게 접근하고 활용할 수 있으며, 다양한 배포 옵션을 통해 실제 프로덕션 환경에서도 사용할 수 있습니다.

---

**참고 링크:**

- [Qwen2.5-Omni GitHub 저장소](https://github.com/QwenLM/Qwen2.5-Omni)
- [Qwen Chat](https://qianwen.aliyun.com)
- [Hugging Face](https://huggingface.co/Qwen)
- [ModelScope](https://modelscope.cn/models/qwen)
