---
title: "Claude Code를 사내 모델로 라우팅하기 - claude-code-router로 온프렘 코딩 인프라 구축"
excerpt: "claude-code-router는 Claude Code의 요청을 작업 종류별로 서로 다른 모델 백엔드로 보내는 라우팅 계층입니다. 실제로 설치해 동작을 확인하고, ThakiCloud K8s 플랫폼에서 자체 vLLM 서빙으로 코드 외부 반출 없이 비용을 통제하는 구성을 정리합니다."
seo_title: "claude-code-router 온프렘 모델 라우팅 - Claude Code 자체 서빙 구축 - Thaki Cloud"
seo_description: "claude-code-router로 Claude Code 트래픽을 자체 호스팅 vLLM, Ollama, OpenRouter 등으로 라우팅하는 방법. 작업별 모델 분기, 온프레미스 코드 보안, 비용 통제를 ThakiCloud K8s 기반으로 구성하는 실전 가이드."
date: 2026-06-24
last_modified_at: 2026-06-24
categories:
  - llmops
tags:
  - claude-code
  - model-routing
  - on-premise
  - vllm
  - cost-optimization
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ko/llmops/claude-code-router-onprem-routing/"
reading_time: true
---

![Claude Code 요청을 여러 모델 백엔드로 분기하는 라우팅 구조](/assets/images/claude-code-router-onprem-routing-diagram.png)

## 개요

Claude Code는 터미널에서 동작하는 에이전트형 코딩 도구입니다. 기본 동작은 Anthropic의 API로 요청을 보내는 것이지만, 모든 요청이 같은 무게를 갖지는 않습니다. 백그라운드 요약, 짧은 자동완성, 긴 컨텍스트 분석, 깊은 추론이 필요한 리팩터링은 서로 다른 모델 등급을 요구합니다. 모든 요청을 가장 비싼 모델로 처리하면 비용이 빠르게 누적되고, 반대로 모든 요청을 값싼 모델로 처리하면 품질이 무너집니다.

`claude-code-router`(이하 CCR)는 이 문제를 라우팅 계층으로 해결합니다. Claude Code와 모델 백엔드 사이에 프록시를 두고, 요청 종류에 따라 서로 다른 제공자와 모델로 트래픽을 분기합니다. 최근 소셜에서는 "Claude Code를 영원히 무료로 쓰는 방법"이라는 자극적인 표현으로 이 도구의 변형판이 회자되었지만, 이 글에서는 과장된 프레이밍을 걷어내고 실제 가치인 모델 라우팅과 자체 호스팅 관점에 집중합니다.

ThakiCloud의 관점에서 CCR이 흥미로운 이유는 분명합니다. 우리는 K8s 위에서 Kueue로 GPU를 큐잉하고 vLLM으로 오픈 모델을 서빙합니다. CCR을 사용하면 Claude Code의 요청을 사내 vLLM 엔드포인트로 보낼 수 있고, 이는 소스 코드를 외부로 내보내지 않으면서 개발 생산성 도구를 운용한다는 보안 요구와 정확히 맞물립니다.

---

## claude-code-router는 무엇인가

CCR은 Anthropic 메시지 형식의 요청을 받아 OpenAI 호환 형식 등으로 변환한 뒤, 설정된 제공자로 전달하는 프록시 서버입니다. Claude Code 클라이언트 자체는 수정하지 않습니다. 환경 변수로 Claude Code가 CCR을 바라보게 만들면, 그 뒤의 라우팅은 전부 CCR이 담당합니다.

핵심 기능은 다음과 같습니다.

- **모델 라우팅**: `default`, `background`, `think`, `longContext`, `webSearch`, `image` 등 요청 유형별로 다른 모델을 지정합니다.
- **멀티 제공자 지원**: OpenRouter, DeepSeek, Ollama, Gemini, Volcengine, SiliconFlow 등 다양한 백엔드를 동시에 등록합니다.
- **요청/응답 변환(transformer)**: 제공자마다 다른 API 규격을 transformer가 흡수합니다. `openrouter`, `deepseek`, `gemini`, `tooluse` 같은 변환기가 내장되어 있습니다.
- **동적 모델 전환**: Claude Code 안에서 `/model` 명령으로 즉시 모델을 바꿉니다.
- **CLI 모델 관리**: `ccr model`로 터미널에서 모델과 제공자를 관리합니다.
- **프리셋과 플러그인**: 설정을 프리셋으로 내보내고 마켓플레이스에서 설치하며, 커스텀 transformer로 기능을 확장합니다.

위 다이어그램은 ThakiCloud 환경을 가정한 라우팅 흐름입니다. 일상적인 코딩(`default`)은 사내 vLLM이 서빙하는 Qwen3 또는 DeepSeek로, 가벼운 백그라운드 작업은 로컬 Ollama로, 깊은 추론이 필요한 경우에만 Anthropic API로, 긴 컨텍스트는 OpenRouter 경유 모델로 보냅니다. 이렇게 하면 요청의 성격과 모델의 비용을 맞출 수 있습니다.

---

## 설치 및 통합

CCR은 npm 글로벌 패키지로 배포됩니다. 실제로 설치한 명령과 출력은 아래와 같습니다.

```bash
npm install -g @musistudio/claude-code-router
```

설치 후 버전을 확인했습니다.

```bash
$ ccr version
claude-code-router version: 2.0.0
```

사용 가능한 명령은 `ccr -h`로 확인할 수 있습니다. 실제 출력의 일부입니다.

```text
Usage: ccr [command] [preset-name]

Commands:
  start         Start server
  stop          Stop server
  restart       Restart server
  status        Show server status
  code          Execute claude command
  model         Interactive model selection and configuration
  preset        Manage presets (export, install, list, delete)
  install       Install preset from GitHub marketplace
  activate      Output environment variables for shell integration
  ui            Open the web UI in browser
  -v, version   Show version information
```

설정 파일은 `~/.claude-code-router/config.json`에 둡니다. 핵심은 `Providers` 배열과 `Router` 객체입니다. ThakiCloud 사내 vLLM과 로컬 Ollama를 함께 등록한 예시 구성입니다.

```json
{
  "LOG": true,
  "API_TIMEOUT_MS": 600000,
  "Providers": [
    {
      "name": "thaki-vllm",
      "api_base_url": "http://vllm.internal.thaki:8000/v1/chat/completions",
      "api_key": "internal",
      "models": ["Qwen3-32B", "deepseek-v3"]
    },
    {
      "name": "ollama",
      "api_base_url": "http://localhost:11434/v1/chat/completions",
      "api_key": "ollama",
      "models": ["qwen2.5-coder:latest"]
    }
  ],
  "Router": {
    "default": "thaki-vllm,Qwen3-32B",
    "background": "ollama,qwen2.5-coder:latest",
    "longContext": "thaki-vllm,deepseek-v3"
  }
}
```

서버를 띄우고 Claude Code를 CCR로 보내는 흐름은 다음과 같습니다.

```bash
ccr start            # 라우터 서버 기동
ccr code "..."       # CCR를 경유해 Claude Code 실행
# 또는 셸 전역으로 환경 변수 적용
eval "$(ccr activate)"
```

`api_base_url`을 사내 엔드포인트로 지정한 순간, 해당 트래픽은 Anthropic이 아니라 우리 클러스터의 vLLM으로 흐릅니다. 즉 코드와 프롬프트가 외부로 나가지 않습니다.

---

## 실제 동작 확인

이번 글에서는 라우터 자체의 설치와 기동까지를 실제로 검증했습니다. npm 글로벌 설치는 1초 내에 끝났고, 버전은 2.0.0, CLI는 `start`/`stop`/`code`/`model`/`preset`/`ui` 등 문서에 명시된 명령을 그대로 노출했습니다. 위에 인용한 출력은 모두 로컬에서 캡처한 실제 결과입니다.

다만 사내 vLLM 엔드포인트로의 실제 추론 왕복은 이 환경에서 측정하지 않았습니다. 유효한 GPU 서빙 엔드포인트와 API 키가 필요하기 때문이며, 검증되지 않은 지연 시간이나 토큰 처리량 수치를 만들어 넣지 않기 위해 의도적으로 비웠습니다. 라우팅 품질과 도구 호출(tool use) 신뢰도는 백엔드 모델에 크게 좌우되므로, 실제 도입 시에는 우리 워크로드로 직접 벤치마크하는 단계가 반드시 필요합니다.

---

## ThakiCloud K8s AI/ML SaaS 플랫폼 적용 및 시사점

CCR의 라우팅 모델은 ThakiCloud가 이미 운용하는 인프라와 자연스럽게 맞물립니다.

첫째, **코드 보안**입니다. 금융, 공공, 의료처럼 소스 코드와 내부 데이터의 외부 반출이 제한되는 고객 환경에서, 개발자가 쓰는 코딩 에이전트의 트래픽을 사내 vLLM으로 묶을 수 있습니다. Claude Code의 사용성을 유지하면서도 프롬프트와 코드가 외부 API로 나가지 않는 구성은, 온프레미스 AI 플랫폼의 명확한 차별점입니다.

둘째, **비용 통제**입니다. 작업별 라우팅은 곧 비용별 라우팅입니다. 자동완성과 백그라운드 요약처럼 빈도가 높지만 난도가 낮은 요청은 자체 서빙하는 소형 코더 모델로, 아키텍처 결정 같은 고난도 추론만 상위 모델로 보내면, 단가가 높은 모델 사용량을 실제로 필요한 곳으로 좁힐 수 있습니다. Kueue로 GPU를 큐잉하고 vLLM의 스케일 동작을 활용하면, 유휴 시간대의 비용도 함께 줄어듭니다.

셋째, **멀티테넌트 운영과의 정합성**입니다. CCR의 제공자/라우터 설정은 텍스트 파일과 프리셋으로 관리됩니다. 테넌트별로 허용 백엔드와 모델을 다르게 묶은 프리셋을 배포하면, 팀마다 다른 모델 정책을 코드로 강제할 수 있습니다. 이는 우리가 추구하는 정책의 코드화 방향과 같습니다.

정리하면 CCR은 그 자체로 제품은 아니지만, 자체 서빙 백엔드와 결합될 때 "외부에 코드를 내보내지 않는 코딩 에이전트"라는 구체적인 가치를 만들어 냅니다. 이는 ThakiCloud가 강조해 온 온프렘, 비용 효율, self-hosting 메시지와 정확히 일치합니다.

---

## 한계 및 반론

라우터를 도입한다고 모든 문제가 풀리지는 않습니다. 냉정하게 볼 지점이 여럿 있습니다.

- **품질 격차**: 라우팅의 가치는 백엔드 모델의 품질에 종속됩니다. 복잡한 멀티스텝 리팩터링이나 미묘한 디버깅에서 오픈 모델이 상위 폐쇄 모델을 항상 따라잡지는 못합니다. 무엇을 어디로 보낼지의 경계 설정이 품질을 좌우합니다.
- **도구 호출 신뢰도**: Claude Code는 도구 호출에 크게 의존합니다. 일부 오픈 모델은 도구 호출 포맷을 일관되게 따르지 못해 transformer 보정이 필요하며, 이 부분이 깨지면 에이전트 루프 전체가 흔들립니다.
- **운영 부담**: 제공자, transformer, 라우팅 규칙은 결국 유지보수 대상입니다. 백엔드 API 규격이 바뀌면 라우터 설정도 따라가야 합니다.
- **"무료" 프레이밍의 함정**: 일부 변형판은 텔레메트리 제거나 안전 가드 제거를 내세우며 "무료"를 강조합니다. 이런 방향은 보안과 약관 측면에서 회사가 권장할 수 없습니다. 우리가 취하는 가치는 무료가 아니라 통제권입니다. 어떤 요청을 어떤 모델로 보낼지를 우리가 정한다는 점입니다.

결론적으로 CCR은 "비용을 줄이는 마법"이 아니라 "라우팅이라는 통제 장치"입니다. 그 통제권을 자체 서빙 인프라와 결합할 때, 보안과 비용이라는 두 축에서 의미 있는 이득을 얻을 수 있습니다.

---

## 출처

- claude-code-router (musistudio): [https://github.com/musistudio/claude-code-router](https://github.com/musistudio/claude-code-router)
- npm 패키지: `@musistudio/claude-code-router` (설치 검증 버전 2.0.0)
- 원 트윗(RT): [https://x.com/hjguyhan/status/2069431792688660982](https://x.com/hjguyhan/status/2069431792688660982)
