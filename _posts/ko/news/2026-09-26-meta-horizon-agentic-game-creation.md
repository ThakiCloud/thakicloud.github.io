---
title: "문장 하나로 게임을 짓는 Meta: Horizon Create와 agentic creation의 베팅"
excerpt: "Meta가 Connect에서 Horizon Create(모바일)와 Horizon Studio(브라우저)를 공개하며, 문장 하나로 2D·3D 모바일 게임을 만드는 agentic creation을 출시했다. '자연어에서 실행 가능한 산출물'이라는 비용 곡선이 꺾였고, 그 베팅을 기업 워크플로에 옮기는 것이 ThakiCloud Paxis의 자리입니다."
seo_title: "Meta Horizon Create·Studio, 문장으로 게임 만들기 | ThakiCloud"
seo_description: "Meta Connect(2026-09-24)에서 공개된 Horizon Create·Horizon Studio 분석. 자연어에서 실행 가능한 산출물(agentic creation)의 비용 곡선이 꺾였고, 분배가 내장된 이유, 그리고 이 베팅을 기업 워크플로에 옮기는 ThakiCloud Paxis의 위치를 정리합니다."
date: 2026-09-26
last_modified_at: 2026-09-26
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "gamepad"
tags:
  - meta
  - horizon
  - agentic-creation
  - game-development
  - natural-language
  - paxis
categories:
  - news
canonical_url: "https://thakicloud.com/tech-blog/ko/news/meta-horizon-agentic-game-creation/"
---

![한 문장(말풍선)에서 흘러나온 빛의 입자가 2D·3D 게임 세계 블록으로 조립되는 추상 이미지](/assets/images/meta-horizon-agentic-game-creation-hero.webp)
*agentic creation의 핵심 개념, 자연어에서 실행 가능한 산출물로.*

## 왜 읽어야 하나

에이전트 플랫폼을 만들거나 도입하는 CTO, Paxis 같은 agent-native cloud를 검토하는 엔지니어라면 이 글이 해당합니다. Meta의 게임 도구가 중요한 이유는, 그 도구가 전제하는 "자연어에서 실행 가능한 산출물"이라는 베팅의 구조가 기업 업무 자동화와 정확히 같기 때문입니다. 결론을 먼저 드립니다. agentic creation의 비용 곡선이 꺾였고 소비자(게임)에서 검증된 이 구조를 기업 워크플로에 옮길 때 "만드는 것"이 아니라 "만든 것을 검증하는 것"이 분수령이 됩니다. ThakiCloud의 Paxis는 바로 그 검증 계층에 서 있습니다.

## 개요

Meta는 2026년 9월 24일경 Connect 행사를 통해 두 개의 AI 기반 게임 제작 도구, Horizon Create와 Horizon Studio를 공개했습니다. [Meta 개발자 블로그](https://developers.meta.com/blog/meta-connect-recap-horizon-create-and-horizon-studio/)에 따르면, 두 도구는 Meta Horizon Engine의 agentic creation 능력을 기반으로 하며 현재 얼리 액세스(early access) 단계입니다.

- **Horizon Create**는 모바일 앱입니다. 사용자는 평이한 자연어(문장)로 2D와 3D 모바일 게임을 만들 수 있습니다.
- **Horizon Studio**는 브라우저 기반 도구입니다. 자연어 프롬프팅에 손으로 직접 조작하는 시각 편집을 더해, 게임을 더 정밀하게 다듬을 수 있게 합니다.

두 도구의 공통점은 "만드는 주체"입니다. 사용자는 코드를 쓰지 않습니다. 문장을 쓰고 엔진이 게임을 짭니다. Create는 그 문장만으로 시작하고 Studio는 문장 + 시각 편집으로 미세 조정을 합니다.

## Meta Horizon Engine: agentic creation이 동작하는 방식

Horizon Create·Studio 뒤에는 Meta Horizon Engine이라는 엔진이 있고 그 핵심이 "agentic creation"입니다. 사용자의 문장을 받으면 엔진이 게임을 "계획하고" "조립하는" 에이전트적 절차를 밟습니다. 게임의 구조(스테이지, 조작, 규칙, 비주얼)를 자연어에서 추론해 실행 가능한 게임 객물로 변환하는 것이 이 절차의 내용입니다.

여기서 Create와 Studio의 차이는 "제어권"을 얼마나 사람에게 돌려주느냐입니다. Create는 문장 하나로 끝까지 엔진이 만듭니다. Studio는 엔진이 만든 것을 사람이 시각적으로 손대서 수정합니다. 즉, Create는 "全自动"에 가깝고 Studio는 "에이전트가 만들고 사람이 다듬는" 협업 구조입니다.

![문장에서 시작해 Horizon Engine이 게임을 조립하고 Create와 Studio가 제어권을 나누며 분배 채널로 이어지는 흐름](/assets/images/meta-horizon-agentic-game-creation-slide-01.png)
*agentic creation의 흐름, 문장에서 실행 가능한 게임으로.*

## 분배가 내장되어 있다는 점

Meta가 강조하는 또 다른 축은 분배입니다. 만든 게임을 Facebook·Instagram 등 Meta 플랫폼에 바로 배포할 수 있다는 점입니다. 이는 기술보다 사업 구조의 이야기입니다. 생성 도구가 아무리 좋아도, 산출물을 도달할 곳이 없으면 끝입니다. Meta는 "만드는 것(agentic creation) + 보는 곳(자사 플랫폼)을 한 지붕 아래" 둔 것입니다.

이 구조가 주는 시사점은, agentic creation은 단독 기술로는 성립하지 않고 "생성 + 분배"의 묶음으로만 성립한다는 점입니다. 소비자 게임에서는 Meta 플랫폼이 분배의 목적지입니다. 기업에서는 분배의 목적지가 내부 워크플로, API, 감사 로그가 됩니다. 이 차이가 아래 Paxis 섹션의 핵심입니다.

## ThakiCloud Paxis 시사점

Paxis는 ThakiCloud의 agent-native cloud로, 자연어에서 실행 가능한 산출물을 만드는 agentic creation을 **기업 워크플로**에서 실현합니다. Meta가 게임이라는 소비자 산출물에 agentic creation을 적용한다면, Paxis는 업무(프로세스, 결정, 보고서, 데이터 파이프라인)에 같은 구조를 적용합니다. 세 가지 연결이 있습니다.

- **산출물 형식의 차이, 구조의 동일.** Meta의 산출물은 게임(2D/3D 모바일 앱)입니다. Paxis의 산출물은 실행 가능한 에이전트 워크플로입니다. 둘 다 "문장 → 계획 → 조립 → 실행 가능한 객물"이라는 같은 파이프라인입니다. 생성 대상이 게임인지 업무인지만 다릅니다.
- **제어권 모델의 이식.** Create(자동)와 Studio(자동 + 사람의 시각 편집)의 이분법은, Paxis의 "자율 에이전트"와 "휴먼 승인 게이트"의 이분법과 정확히 대응합니다. Meta는 사람에게 "비주얼 편집"을, Paxis는 사람에게 "결정 승인"을 돌려줍니다. 둘 다 "에이전트가 만들고, 사람이 검증한다"는 구조입니다.
- **분배의 목적지.** Meta의 분배는 자사 소셜 플랫폼입니다. Paxis의 분배는 기업 내 시스템(데이터베이스, API, 감사 로그)입니다. agentic creation을 "쓸 만한 산출물"로 만드는 것은 분배 계층이며 기업에서는 그 계층에 정책·감사가 붙습니다.

Paxis의 차별점은 바로 이 검증 계층입니다. Paxis는 스킬·도구·정책·감사 로그를 일급 리소스로 다루고 모든 실행을 정책 게이트와 감사 로그로 통과시킵니다. agentic creation이 만든 산출물이 기업에서 실행되기 전에 "이 산출물은 어떤 정책에 부합하고 누가 승인했는가"를 묻는 계층입니다. Meta가 게임에 이걸 붙이지 않아도 되는 것은, 게임의 실패가 사업 리스크가 아니기 때문입니다. 업무에서 실패는 리스크입니다. 그래서 Paxis는 검증 계층을 필수로 둡니다.

## 한계 및 반론

Meta의 agentic creation을 과대하게 읽지 말아야 할 이유도 있습니다.

- **얼리 액세스.** 두 도구 모두 초기 단계입니다. 문장 하나로 만드는 게임의 품질이 실제 출시 수준인지, 아직 입증되지 않았습니다.
- **게임의 깊이.** 문장에서 2D/3D 모바일 게임이 만들어지지만, 그것이 "잘 만든 게임"인지, "실행 가능한 게임"인지는 다른 문제입니다. agentic creation은 실행 가능성은 증명해도, 완성도는 증명하지 않습니다.
- **분배 잠금.** Meta 플랫폼에 분배가 내장된 것은 강점이지만, 동시에 산출물이 Meta 생태계에 묶이는 의미도 있습니다. 외부 분배·외부 데이터 연동은 제한될 수 있습니다.
- **기업과 소비자의 거리.** 게임에서 검증된 agentic creation이, 기업 업무에서 그대로 성립한다고 단정할 수는 없습니다. 업무의 산출물은 게임과 달리 오차 용인이 낮고 정책·감사가 필수입니다. Meta의 "자동" 모델이 기업에서는 "자동 + 승인"으로 바뀌어야 한다는 점은, Paxis가 존재하는 이유이지만, 동시에 agentic creation을 기업에 이식하기까지의 거리를 보여줍니다.

## 정리

Meta의 Horizon Create·Studio는 "문장 하나로 게임을 만든다"는 소비자 프로덕트입니다. 그러나 이 프로덕트가 확인하는 것은 agentic creation이라는 구조의 비용 곡선이 꺾였다는 사실입니다. 자연어에서 실행 가능한 산출물을 만드는 비용이, 사람이 코드를 쓰는 비용보다 낮아진 시점이 온 것입니다.

이 구조를 기업에 옮길 때, 분수령은 "만드는 것"이 아니라 "만든 것을 검증하는 것"입니다. Meta는 게임이라는 산출물에 이걸 붙이지 않아도 되지만, Paxis는 업무라는 산출물에 정책·감사·승인을 필수로 붙입니다. agentic creation의 다음 전장은 생성이 아니라 검증이며 ThakiCloud의 Paxis는 그 전장에 서 있습니다.

*이 글의 사실(도구명, 플랫폼, 얼리 액세스, 분배 채널)은 Meta 개발자 블로그 기반이며 발표 시기는 보도가 일치하는 범위에서 인용했습니다. 미확인 세부 사양은 사용하지 않았습니다.*
