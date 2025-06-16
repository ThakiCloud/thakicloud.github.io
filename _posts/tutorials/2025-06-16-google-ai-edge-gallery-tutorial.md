---
title: "Google AI Edge Gallery 튜토리얼: 온디바이스 GenAI 앱 시작하기"
excerpt: "Google AI Edge Gallery 앱을 설치하고, 다양한 로컬 GenAI 모델을 활용해 이미지 질의·프롬프트 실험·성능 벤치마킹을 수행하는 방법을 단계별로 안내합니다."
date: 2025-06-16
categories:
  - tutorials
  - dev
tags:
  - google-ai-edge
  - on-device
  - generative-ai
  - android
author_profile: true
toc: true
toc_label: Google AI Edge Gallery Guide
---

## 개요

[Google AI Edge Gallery](https://github.com/google-ai-edge/gallery)는 **Android** 기기에서 완전히 오프라인으로 GenAI 모델을 실행·체험할 수 있는 실험적 오픈소스 앱입니다. LiteRT 기반 경량 런타임과 Hugging Face 통합을 통해 여러 LLM/VLM을 다운로드하고, 이미지 질문·프롬프트 랩·채팅·성능 측정을 한 번에 수행할 수 있습니다. 본 튜토리얼에서는 APK 설치부터 **모델 가져오기**, **Ask Image**, **Prompt Lab** 활용, 그리고 **성능 지표 해석**까지 전 과정을 다룹니다. \[Repo README\]

## 1. 사전 준비 사항

- Android 10(API 29) 이상 스마트폰 또는 에뮬레이터
- 저장 공간 5 GB 이상, RAM 6 GB 이상 권장
- **알파 버전 주의**: Play Protect 차단 시 수동 허용 필요

## 2. APK 다운로드 및 설치

1. [Releases 페이지](https://github.com/google-ai-edge/gallery/releases)에서 최신 `gallery-<version>.apk` 파일을 다운로드합니다.
2. 기기에서 **설정 → 보안 → 알 수 없는 앱 허용**을 활성화한 뒤 APK를 설치합니다.
3. 처음 실행 시 **모델 저장 위치**(내부 저장소·SD 카드)를 선택합니다.

> 회사 단말 정책이 있을 경우 README의 "corporate devices" 가이드를 참고하세요. \[Repo README\]

## 3. 첫 실행 & 모델 다운로드

### 3.1 기본 UI 구조

- **Explore**: 모델 카드 목록 및 사용 사례 갤러리
- **Ask Image**: Vision-Language 모델로 이미지 질의
- **Prompt Lab**: 단일 턴 프롬프트 실험 공간
- **AI Chat**: 다중 턴 LLM 채팅
- **Performance**: TTFT·Latency 실시간 그래프

### 3.2 모델 선택

1. `Explore` 탭에서 **Add Model** 버튼을 눌러 Hugging Face 모델 리스트를 불러옵니다.
2. `phi-3-mini-4k-instruct`(LLM) 또는 `foisal/pali-3-mini`(VLM) 등 원하는 모델을 선택 후 *Download*.
3. 다운로드 완료 후 **Set Active**를 눌러 현재 유효 모델로 지정합니다.

LiteRT `.task` 형식을 직접 보유하고 있다면 **Bring Your Own Model → Import Task**를 통해 로컬 파일을 선택할 수 있습니다.

## 4. 기능별 활용

### 4.1 Ask Image

1. 상단 **Upload** 아이콘을 눌러 갤러리에서 이미지를 선택하거나 카메라로 촬영합니다.
2. 입력창에 질문을 작성합니다. 예: `이 다이어그램의 핵심 흐름을 요약해줘.`
3. **Generate**를 누르면 모델이 오프라인으로 추론 후 답변을 제공합니다.
4. **Share** 아이콘으로 결과를 클립보드 또는 노트 앱으로 복사할 수 있습니다.

### 4.2 Prompt Lab

- **Preset**에서 `Summarize`, `Rewrite`, `Code` 등을 선택하거나 자유 입력합니다.
- 토큰 길이, 온도, 톱-p를 슬라이더로 조정해 즉시 실험 결과를 비교하세요.

### 4.3 AI Chat

- Chat history가 로컬에 암호화 저장됩니다. 세션 삭제는 **⋮ → Clear History**.
- Multi-turn 성능 확인 시 **Performance** 탭을 열어 토큰/초(decoding speed)를 모니터링합니다.

## 5. 성능 지표 이해

| 지표 | 설명 |
| --- | --- |
| **TTFT** | First token 생성까지 걸린 시간 (ms) |
| **Decode Speed** | 초당 생성 토큰 수 (tok/s) |
| **Latency** | 전체 응답까지 소요 시간 (ms) |

모델·프롬프트 길이·기기 SoC에 따라 크게 변동합니다. 동일 기기에서 여러 모델을 비교해 최적 선택을 도출하세요.

## 6. 고급: LiteRT `.task` 모델 변환

```bash
# 1) tflite_convert 예시 (PyTorch → LiteRT)
python convert_to_litert.py \
  --model-id meta-llama/Llama-3-8B-Instruct \
  --outfile llama3_8b.task

# 2) 기기로 복사 후 Import Task
adb push llama3_8b.task /sdcard/Download/
```

LiteRT 변환 스크립트와 지원 모델 목록은 [Project Wiki](https://github.com/google-ai-edge/gallery/wiki)에서 확인할 수 있습니다.

## 7. 문제 해결 FAQ

| 증상 | 해결책 |
| --- | --- |
| **앱이 모델 다운로드 중 멈춤** | VPN 사용 여부 확인, 저장 공간 부족 여부 확인 |
| **Inference failure: out of memory** | 설정 → *Low-RAM Mode* 활성화 또는 더 작은 모델 선택 |
| **Prompt Lab 결과가 비어 있음** | 온도 0, max tokens 매우 낮음 → 매개변수 조정 |

## 8. 결론

Google AI Edge Gallery는 인터넷 연결 없이도 GenAI 모델을 실험할 수 있는 훌륭한 테스트베드입니다. 본 튜토리얼을 통해 모델 다운로드, 이미지 질의, 프롬프트 실험, 성능 분석까지 핵심 기능을 익혔다면, 이제 자신의 **온디바이스 AI** 워크플로에 적극 활용해 보세요!

> 프로젝트 소스와 최신 업데이트는 GitHub에서 확인하세요: [google-ai-edge/gallery](https://github.com/google-ai-edge/gallery) \[Repo README\] 