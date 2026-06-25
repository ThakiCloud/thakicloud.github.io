---
title: "논문 쓰는 AI 에이전트 - 오픈소스 Skill 패키지로 작성 워크플로 옮기기"
excerpt: "교수의 논문 작성 노하우를 Codex, Claude Code, Gemini 어디서나 불러 쓰는 Skill 패키지로 묶은 오픈소스 프로젝트가 화제입니다. 단순 프롬프트 모음과 무엇이 다른지, Agent Skill이라는 형식이 왜 중요한지, 그리고 수백 개의 Skill로 에이전트 플랫폼을 운영하는 ThakiCloud 관점에서 이 흐름이 무엇을 시사하는지 정리합니다."
seo_title: "오픈소스 논문 작성 Skill 패키지 분석 (2026) - Thaki Cloud"
seo_description: "Research-Paper-Writing-Skills는 ML/CV/NLP 논문 작성 노하우를 Codex, Claude Code, Gemini에서 공통으로 쓰는 Agent Skill 패키지입니다. Skill 형식이 프롬프트와 무엇이 다른지, 설치와 사용법, 그리고 Skill 중심 에이전트 플랫폼을 운영하는 ThakiCloud의 관점과 한계를 함께 정리합니다."
date: 2026-06-26
last_modified_at: 2026-06-26
categories:
  - dev
tags:
  - ai-agent
  - agent-skills
  - claude-code
  - paper-writing
  - llm
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ko/dev/ai-agent-research-paper-skills/"
reading_time: true
---

논문 마감이 가까워지면 연구자는 같은 작업을 반복합니다. 서론을 다시 다듬고, 초록의 주장과 근거가 맞물리는지 확인하고, 리뷰어가 물고 늘어질 만한 문장을 미리 손봅니다. 이 노하우는 대개 지도교수의 머릿속이나 흩어진 메모에 있습니다. 최근 X에서 화제가 된 [Research-Paper-Writing-Skills](https://github.com/Master-cai/Research-Paper-Writing-Skills)는 바로 이 노하우를 AI 코딩 에이전트가 그대로 불러 쓸 수 있는 Skill 패키지로 묶은 오픈소스 프로젝트입니다. 핵심은 "또 하나의 프롬프트 모음"이 아니라, Codex와 Claude Code, Gemini 어디서나 같은 능력을 끼워 넣는 이식 가능한 형식이라는 점입니다.

![중앙의 모듈형 지식 단위가 세 갈래 데이터 흐름을 통해 서로 다른 세 도구로 퍼져 나가는 추상 이미지](/assets/images/ai-agent-research-paper-skills-hero.png)

## 개요

이 프로젝트는 중국 저장대학교 펑쓰다(彭思达) 교수가 공개한 연구 입문 노트 [learning_research](https://github.com/pengsida/learning_research)를 바탕으로, 논문 작성 노하우를 재구성해 Agent Skill 패키지로 포장한 것입니다. 저장소 설명에 따르면 ML, CV, NLP 논문 작성에 초점을 맞췄고, Codex와 Claude Code, Gemini를 대상으로 큐레이션과 구조화 작업을 거쳤습니다. 원저작자의 글을 그대로 베낀 것이 아니라, 흩어진 조언을 작업 단위로 쪼개 에이전트가 호출할 수 있는 재사용 가능한 능력으로 만든 것이 기여의 핵심입니다.

왜 이런 형식이 지금 주목받을까요. AI 코딩 에이전트가 보편화되면서, 사람들은 모델 자체보다 "이 모델에게 무엇을 어떻게 시킬 것인가"를 자산으로 보기 시작했습니다. 잘 정리된 작업 지식은 한 번 만들어 두면 여러 도구와 여러 사람에게 복제됩니다. 논문 작성처럼 절차가 분명하고 품질 기준이 명확한 작업은 이 형식과 특히 잘 맞습니다. ThakiCloud 역시 내부 운영의 상당 부분을 수백 개의 Skill로 구성하고 있어, 이 흐름을 단순한 유행이 아니라 에이전트 운영의 구조적 변화로 보고 있습니다.

![단일 오픈소스 패키지 한 벌이 Codex, Claude, Gemini 세 파운데이션 모델에서 공통으로 호출되는 구조를 요약한 슬라이드](/assets/images/ai-agent-research-paper-skills-slide-03.png)

## Agent Skill이란 무엇인가

Agent Skill은 에이전트에게 특정 작업을 수행하는 방법을 알려 주는 패키지입니다. 보통 `SKILL.md`라는 지시문 파일을 중심에 두고, 필요하면 참조 문서나 스크립트, 템플릿을 함께 담습니다. 핵심 성질은 세 가지입니다. 첫째, 버전 관리가 됩니다. 저장소에 두고 수정 이력을 추적할 수 있으므로 단발성 프롬프트와 달리 자산으로 축적됩니다. 둘째, 필요할 때만 불러옵니다. 모든 지식을 매번 컨텍스트에 욱여넣는 대신, 작업과 관련된 Skill만 그 순간 로드합니다. 셋째, 하네스에 종속되지 않습니다. 같은 Skill을 Claude Code에서도, Codex에서도, Gemini에서도 쓸 수 있는 것이 목표입니다.

![프롬프트 복붙과 Agent Skill 시스템을 버전 관리, 컨텍스트 로딩, 하네스 종속성 세 축으로 비교한 표 슬라이드](/assets/images/ai-agent-research-paper-skills-slide-04.png)

이 세 번째 성질이 이 프로젝트의 가치를 가장 잘 설명합니다. 모델은 계속 바뀌고 CLI 도구도 계속 바뀝니다. 그러나 "좋은 서론을 쓰는 법"이라는 작업 지식은 그보다 훨씬 오래갑니다. 능력을 도구가 아니라 Skill 쪽에 쌓아 두면, 도구를 갈아탈 때마다 노하우를 다시 만들 필요가 없습니다. 이것이 우리가 내부에서 "얇은 하네스, 두꺼운 Skill"이라고 부르는 원칙입니다. 모델 루프와 권한, 파일 입출력 같은 하네스는 얇게 유지하고, 도메인 지식과 판단, 실패 사례는 Skill에 두텁게 쌓는 것입니다.

![이식 가능한 Skill 패키지가 SKILL.md 지시문과 참조 자료를 담은 채, Claude Code와 Codex, Gemini 세 하네스에 똑같이 끼워져 논문 작성 작업을 수행하는 구조](/assets/images/ai-agent-research-paper-skills-diagram.png)

위 그림의 핵심은 가운데 Skill 패키지가 단 한 벌이라는 점입니다. 세 도구가 각자 다른 프롬프트를 들고 있는 것이 아니라, 같은 작업 지식을 공유합니다. 프롬프트 한 줄을 단톡방에 붙여 넣는 방식과 본질적으로 다른 지점이 여기입니다.

## Research-Paper-Writing-Skills 살펴보기

이 패키지가 다루는 작업은 논문 작성의 실제 단계와 맞닿아 있습니다. 공개된 사용 예시를 보면, 서론을 개선하라는 호출(`$research-paper-writing`)로 글의 도입부를 다듬거나, 초록을 다시 쓰되 주장과 근거가 짝을 이루는지 검사하는 식입니다. 즉 "글을 잘 써 줘"라는 막연한 요청이 아니라, 논문에서 반복적으로 발생하는 구체적 하위 작업을 각각의 능력으로 분리한 구조입니다. 이는 동사 하나에 결과물 하나를 대응시키는 좋은 프롬프트 설계 원칙과도 일치합니다.

여러 AI 코딩 도구를 함께 겨냥한 점도 눈에 띕니다. 사용자는 자신이 쓰는 환경의 Skill 디렉터리에 패키지를 복사해 넣는 것만으로 같은 능력을 활성화할 수 있습니다. 이런 다중 하네스 지향은 이 프로젝트만의 특징이 아니라, Codex 중심의 학술 Skill 모음이나 범용 AI 리서치 Skill 라이브러리 등 최근 등장한 여러 오픈소스 프로젝트가 공유하는 방향입니다. 연구 워크플로 전반을 Skill 생태계로 옮기려는 시도가 동시다발적으로 진행되고 있다는 신호입니다.

한 가지 분명히 해 둘 점이 있습니다. 이 글은 저장소의 공개 설명과 사용 예시를 근거로 작성했으며, 별점 수나 내부 파일 구성 같은 세부 수치는 시점에 따라 달라질 수 있어 단정하지 않았습니다. 실제 도입을 검토한다면 저장소 원문과 라이선스, 그리고 원저작자 노트의 출처 표기를 직접 확인하시기를 권합니다.

## 설치 및 사용

Agent Skill의 설치 모델은 대체로 단순합니다. 패키지를 내려받아 사용하는 도구가 인식하는 Skill 경로에 두면, 에이전트가 작업에 맞춰 해당 Skill을 불러옵니다. 일반적인 흐름은 다음과 같습니다.

```bash
# 저장소를 클론합니다
git clone https://github.com/Master-cai/Research-Paper-Writing-Skills.git

# 사용하는 도구의 Skill 디렉터리에 복사합니다 (도구별 경로는 각 문서를 확인)
# 예: Claude Code 프로젝트의 .claude/skills/ 하위로 배치
cp -r Research-Paper-Writing-Skills/<skill-dir> .claude/skills/
```

배치가 끝나면 에이전트 세션에서 해당 Skill을 호출해 작업을 시킵니다. 서론 초안을 손보거나, 초록의 주장과 근거 정합성을 점검하는 식의 요청을 자연어로 던지면, Skill에 담긴 절차와 점검 기준이 적용됩니다. 도구마다 Skill을 인식하는 경로와 호출 관례가 조금씩 다르므로, 실제 배치 경로는 각 도구의 문서를 따르는 것이 안전합니다. 중요한 것은 한 번 배치한 Skill이 그 도구의 모든 세션에서 재사용된다는 점입니다. 매번 같은 프롬프트를 복사해 붙이는 수고가 사라집니다.

![환경 복사, 명령어 호출, 특정 작업 지시, 결과 도출로 이어지는 4단계 사용 흐름 슬라이드](/assets/images/ai-agent-research-paper-skills-slide-06.png)

## ThakiCloud K8s AI/ML SaaS 플랫폼 적용 및 시사점

ThakiCloud의 AI 플랫폼은 Kubernetes 위에서 다양한 고객의 에이전트와 배치 작업을 운영합니다. 우리 내부 운영 자체가 이미 Skill 중심으로 구성되어 있어, 이 프로젝트가 보여 주는 형식은 낯설지 않습니다. 오히려 외부에서 같은 패턴이 빠르게 확산되고 있다는 점이 의미가 큽니다.

![사내 표준화, 벤더 독립성, K8s 네이티브 세 가지로 정리한 ThakiCloud 멀티테넌트 플랫폼 확장 슬라이드](/assets/images/ai-agent-research-paper-skills-slide-07.png)

첫째, 데이터 과학자와 연구 인력에게 직접적인 가치가 있습니다. 플랫폼을 다루는 팀은 논문과 기술 보고서를 자주 작성합니다. 검증된 논문 작성 Skill을 사내 표준 도구에 얹어 두면, 서론 구조나 초록의 주장-근거 정합성처럼 실수하기 쉬운 부분을 일관된 기준으로 점검할 수 있습니다. 모델 등급을 올리지 않고도 평균 품질을 끌어올리는 방식입니다.

둘째, 하네스 독립성은 멀티테넌트 운영과 잘 맞습니다. 고객마다 선호하는 에이전트 환경이 다를 수 있는데, 능력을 Skill에 담아 두면 환경이 달라도 같은 작업 지식을 재사용할 수 있습니다. 특정 벤더의 도구에 능력이 묶이지 않으므로, 온프레미스 요구가 강한 고객 환경에도 같은 자산을 이식하기 수월합니다. 이는 자체 호스팅과 비용 효율을 중시하는 우리 전략과 결이 같습니다.

셋째, Skill을 운영 자산으로 다루는 규율이 함께 필요하다는 교훈도 줍니다. Skill은 색인에 올라간 순간부터 매 세션 컨텍스트 비용을 치릅니다. 그래서 우리는 새 Skill마다 "이게 없으면 에이전트가 틀리는가"라는 질문을 통과시키고, 실패 사례를 명시적으로 적어 둡니다. 외부에서 좋은 Skill을 도입할 때도 같은 게이트를 적용하면, 늘어나는 Skill이 오히려 검색 정확도를 떨어뜨리는 부작용을 줄일 수 있습니다.

## 한계 및 반론

이 접근에는 분명한 약점도 있습니다. 가장 먼저, 생성된 글의 품질을 객관적으로 측정한 공개 지표가 없습니다. 논문 작성은 본질적으로 판단이 개입하는 작업이라, Skill이 만든 초안이 사람 기준에 얼마나 부합하는지는 결국 사람이 검토해야 합니다. 이 글에서도 성능 수치를 제시하지 않은 이유가 여기에 있습니다. 캡처한 실측이 없는데 수치를 지어내는 것은 가장 피해야 할 일입니다.

![엄격한 게이트키핑, 인간의 최종 책임, 공개 지표의 부재 세 가지 한계를 정리한 슬라이드](/assets/images/ai-agent-research-paper-skills-slide-08.png)

다음으로, 출처와 파생 저작의 문제가 있습니다. 이 패키지는 타인의 공개 노트를 재구성한 결과물입니다. 원저작자를 명시하고 있더라도, 도입하는 쪽에서는 라이선스와 출처 표기 범위를 직접 확인할 책임이 있습니다. 사내 표준에 얹는다면 더욱 그렇습니다.

마지막으로, 작성 보조가 사고를 대체하지는 않습니다. 좋은 서론은 좋은 연구에서 나옵니다. Skill은 표현과 점검을 거들 뿐, 빈약한 결과를 충실한 논문으로 둔갑시키지 못합니다. 도구가 채워 주는 부분과 연구자가 끝까지 책임져야 하는 부분을 혼동하지 않는 것이 이 형식을 건강하게 쓰는 전제입니다.

![프롬프트를 멈추고 자산을 구축하라는 메시지로 마무리하는 슬라이드](/assets/images/ai-agent-research-paper-skills-slide-09.png)

## 출처

- Research-Paper-Writing-Skills: [https://github.com/Master-cai/Research-Paper-Writing-Skills](https://github.com/Master-cai/Research-Paper-Writing-Skills)
- 원저작 노트 learning_research (펑쓰다): [https://github.com/pengsida/learning_research](https://github.com/pengsida/learning_research)
