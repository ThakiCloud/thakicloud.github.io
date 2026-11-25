---
title: "우리는 왜 AI 에이전트와 함께 일하는가"
excerpt: "챗봇과 워크플로, 에이전트의 차이를 이해하고 실제 업무에 필요한 자율성과 통제의 균형을 설계합니다."
date: 2026-11-26
last_modified_at: 2026-11-26
tags:
  - ThakiCloud
  - AInative
  - AI에이전트
  - 자동화
  - 워크플로
author_profile: true
toc: true
toc_label: 목차
canonical_url: "https://thakicloud.com/tech-blog/ko/culture/working-with-agents/"
categories:
  - culture
---

![빛의 원형 테이블 주위에 작은 형광 인물이 둘러앉은 추상 이미지]({{ '/assets/images/working-with-agents-hero.webp' | relative_url }})

*Why We Work with AI Agents · AI-Native Culture 04*

## AI에게 질문하는 것과 업무를 맡기는 것은 다릅니다

챗봇은 질문에 답하거나 초안을 작성하는 데 유용합니다. 그러나 실제 업무에는 여러 시스템에서 데이터를 조회하고, 조건을 비교하고, 결과를 검증하고, 필요한 승인 절차를 거쳐 상태를 변경하는 과정이 포함됩니다. 업무의 연속성을 가진 AI 시스템을 설계하려면 대화의 품질만으로는 충분하지 않습니다.

우리가 AI 에이전트에 관심을 갖는 이유는 인간이 반복적인 실행 단계에 소비하는 시간을 줄이고 문제 정의와 판단에 더 집중할 수 있는 가능성 때문입니다.

## 에이전트가 반드시 정답은 아닙니다

Anthropic의 엔지니어링 가이드는 사전에 정의한 경로로 도구와 모델을 실행하는 워크플로와, 모델이 실행 경로를 동적으로 정하는 에이전트를 구분합니다. 또한 필요한 경우에만 복잡성을 늘리는 접근을 권장합니다.[1]

매일 정해진 지표를 조회해 보고서를 만드는 작업에 복잡한 다중 에이전트가 필요하지 않을 수 있습니다. 반면 장애 원인이 다양한 시스템에 흩어져 있고 조사 과정이 매번 달라진다면 제한된 범위의 에이전트가 유용할 수 있습니다.

| 방식 | 적합한 예시 | 주요 통제 |
|---|---|---|
| 단일 모델 호출 | 요약, 분류, 초안 | 입력과 출력 검증 |
| 정형 워크플로 | 정기 보고, 데이터 검증 | 단계별 조건과 재시도 |
| 에이전트 | 복합 장애 조사, 동적 탐색 | 권한, 예산, 중단 조건 |

## 실제 업무를 하나의 미션으로 설계합니다

예를 들어 서비스의 장애 분석을 지원하는 시스템을 생각해 보겠습니다. 사용자가 장애 조사를 요청하면 시스템은 승인된 모니터링 지표와 로그를 조회하고 최근 변경 사항을 분석합니다. 조사 결과에는 가설과 근거, 확인되지 않은 항목이 구분되어야 합니다. 시스템이 복구 방안을 추천하더라도 운영 환경의 변경은 별도의 승인된 절차를 따릅니다.

이 과정에서 도구 호출 기록, 작업 상태, 사용한 모델 버전, 비용 및 검증 결과가 남아야 합니다. 네트워크 오류나 중복 호출이 발생하더라도 작업 상태가 손상되지 않도록 재시도와 멱등성을 설계해야 합니다. 종료 조건을 정하지 않은 에이전트는 같은 작업을 반복하며 비용을 발생시킬 수 있습니다.

## 인간의 역할이 사라지는 것은 아닙니다

Satya Nadella는 에이전트형 애플리케이션에 메모리와 권한, 행동 공간이 결합되는 방향을 설명했습니다.[2] Microsoft의 2025년 Work Trend Index는 사람과 에이전트가 함께 일하는 조직 모델을 제안했습니다.[3] 이는 모든 업무가 자율 에이전트로 전환된다는 확정적 사실이 아니라 기업이 제시한 변화의 관점입니다.

업무 목적과 허용 범위를 정의하고 결과를 승인하는 역할은 여전히 중요합니다. 특히 고객에게 메시지를 보내거나 자금을 집행하거나 운영 시스템을 변경하는 작업에는 위험 수준에 맞는 통제가 필요합니다. NIST의 위험관리 지침은 이러한 운영 설계의 참고 자료가 됩니다.[4]

## 성공의 기준은 에이전트 수가 아닙니다

동일한 업무에 대해 기존 처리시간, 재작업률, 성공률, 모델 비용과 사람의 검토 시간을 비교합니다. 예상치 못한 동작을 멈출 수 있는지, 완료되지 않은 일을 완료로 표시하지 않는지도 확인해야 합니다. 에이전트가 더 복잡하고 비싸지만 결과가 비슷하다면 단순한 워크플로를 선택하는 것이 합리적입니다.

우리가 만들고 싶은 업무 환경은 AI에게 무조건 많은 권한을 주는 환경이 아닙니다. 사람은 목표와 책임을 유지하고, AI는 명확한 범위에서 실행 능력을 확장하는 환경입니다. 자동화의 수준보다 중요한 것은 업무가 정확하고 안전하게 끝나는가입니다.

## 출처

1. [Anthropic, Building Effective Agents (2024)](https://www.anthropic.com/engineering/building-effective-agents)
2. [Satya Nadella, Introducing CoreAI: Platform and Tools (2025-01-13)](https://blogs.microsoft.com/blog/2025/01/13/introducing-core-ai-platform-and-tools/)
3. [Jared Spataro, Microsoft Work Trend Index (2025-04-23)](https://blogs.microsoft.com/blog/2025/04/23/the-2025-annual-work-trend-index-the-frontier-firm-is-born/)
4. [NIST, AI RMF: Generative AI Profile, AI 600-1 (2024)](https://doi.org/10.6028/NIST.AI.600-1)

## AI-Native Culture 시리즈

1. [AI를 빼앗는 기업과 AI를 제공하는 기업](/tech-blog/ko/culture/ai-native-organization-taking-vs-giving/)
2. [AI 시대에 관리자는 무엇을 해야 하는가](/tech-blog/ko/culture/leadership-in-ai-era/)
3. [개인의 지식을 조직의 지능으로](/tech-blog/ko/culture/organizational-intelligence/)
4. [우리는 왜 AI 에이전트와 함께 일하는가](/tech-blog/ko/culture/working-with-agents/)
5. [AI 시대에도 엔지니어링의 본질은 변하지 않는다](/tech-blog/ko/culture/engineering-fundamentals/)
6. [AI가 만든 결과는 누가 책임지는가](/tech-blog/ko/culture/accountability-for-ai/)
7. [AI 시대의 주니어는 어떻게 성장하는가](/tech-blog/ko/culture/growing-junior-talent/)
8. [AI를 도입한 기업과 AI-Native 기업의 차이](/tech-blog/ko/culture/ai-native-organization/)
