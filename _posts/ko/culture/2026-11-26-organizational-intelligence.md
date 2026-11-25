---
title: "개인의 지식을 조직의 지능으로"
excerpt: "사내 지식과 업무 맥락을 권한, 출처, 유효기간과 함께 관리하는 조직 메모리의 문화와 기술을 제안합니다."
date: 2026-11-26
last_modified_at: 2026-11-26
tags:
  - ThakiCloud
  - AInative
  - 조직지식
  - 메모리
  - RAG
author_profile: true
toc: true
toc_label: 목차
canonical_url: "https://thakicloud.com/tech-blog/ko/culture/organizational-intelligence/"
categories:
  - culture
---

![상호 연결된 노드가 뇌 같은 구조를 이루는 발광 격자 추상 이미지]({{ '/assets/images/organizational-intelligence-hero.webp' | relative_url }})

*From Individual Knowledge to Organizational Intelligence · AI-Native Culture 03*

## 핵심 인력이 떠나면 무엇이 남을까요?

오랫동안 운영된 시스템에는 문서만 읽어서는 알 수 없는 지식이 많습니다. 특정 설계를 선택한 이유, 이전에 실패했던 실험, 장애가 발생하는 조건, 고객마다 달라지는 계약의 예외 등이 그렇습니다. 이 지식이 개인의 기억 속에만 존재한다면 조직은 같은 시행착오를 반복하게 됩니다.

AI는 흩어진 정보를 검색하고 정리하는 비용을 낮출 수 있습니다. 그러나 파일을 벡터 데이터베이스에 넣는 것만으로 조직의 지능이 만들어지지는 않습니다. 정보가 정확한지, 누가 볼 수 있는지, 언제까지 유효한지, 어떤 상황에 적용되는지 알아야 합니다.

## 지식 공유는 개인을 대체하는 것이 아닙니다

Brynjolfsson, Li, Raymond의 2025년 고객 상담 연구는 AI 지원의 효과가 경험과 숙련도에 따라 다르며 초보 직원에게 상대적으로 크게 나타났다고 보고합니다.[1] 숙련자의 행동 패턴이 도구를 통해 전달될 수 있다는 가능성을 보여줍니다. 다만 이것은 특정 상담 환경에서 관찰된 결과로, 모든 지식 업무에 자동으로 일반화할 수는 없습니다.

Microsoft CEO Satya Nadella가 2025년 설명한 에이전트형 애플리케이션의 방향에서도 메모리와 권한은 중요한 요소입니다.[2] 지식을 기억하는 능력과 그 지식을 사용할 자격은 함께 설계되어야 합니다.

## 조직 메모리를 만드는 네 가지 층

| 지식 계층 | 저장 대상 | 운영 원칙 |
|---|---|---|
| 원천 기록 | 정책, 계약, 코드, 업무 데이터 | 원본과 버전 유지 |
| 구조화 지식 | 설계 결정, 용어, 절차, 사실 | 담당자와 출처 명시 |
| 업무 맥락 | 프로젝트 상태, 승인, 작업 이력 | 접근권한과 유효기간 |
| 학습 기록 | 장애 분석, 실험 결과, 개선 사례 | 검증 후 공유 |

검색증강생성(RAG)은 질문과 관련된 근거를 찾아 모델 입력으로 전달하는 구현 방법 중 하나입니다. 정형 데이터는 SQL이나 업무 API를 활용할 수 있고, 관계가 중요한 데이터는 그래프 형태로 관리할 수도 있습니다. 모든 정보를 하나의 메모리 저장소에 넣을 필요는 없습니다.

사용자가 질문하면 먼저 신원을 확인하고 접근 가능한 자료를 검색합니다. 답변은 근거와 버전을 제공해야 합니다. 상충하는 자료가 발견되면 최신 문서라는 이유만으로 자동 확정하지 말고 정책의 발효일과 승인 상태를 확인합니다. 근거가 부족하면 확인 불가를 표시하는 것이 적절합니다.

## 실패를 기록하는 조직

성공한 실험만 기록하면 지식 기반은 편향됩니다. 실패한 배포, 기대보다 효과가 낮았던 모델, 재현되지 않은 결과도 남겨야 합니다. 예를 들어 모델 압축 실험에서 비용이 절감됐지만 특정 언어의 품질이 저하됐다면, 모델 버전과 평가 조건, 판정 근거를 함께 보존해야 이후 팀이 동일한 오류를 피할 수 있습니다.

Microsoft의 2026년 보고서는 조직을 학습 시스템으로 발전시키는 관점을 제안합니다.[3] 이를 구현하려면 AI가 작성한 요약을 곧바로 사실로 저장하는 것이 아니라 검토된 결정과 검증되지 않은 가설을 구분해야 합니다.

## 기억할 권리만큼 잊을 의무도 중요합니다

퇴사자의 개인정보, 고객 비밀, 만료된 계약까지 무한히 저장해서는 안 됩니다. 보존기간과 삭제 요청, 접근권한 변경을 원문뿐 아니라 검색 인덱스와 파생 데이터에도 반영할 수 있어야 합니다. NIST의 생성형 AI 위험관리 프로파일은 이러한 설계에서 신뢰성과 위험을 함께 고려하는 참고점입니다.[4]

우리가 지향하는 지식 문화는 개인의 전문성을 낮추는 것이 아니라 더 많은 사람이 그 전문성을 활용하고 발전시키도록 만드는 것입니다. 지식을 가진 사람이 떠날 때 조직도 함께 기억을 잃지 않도록, 지식 공유를 일의 일부로 만들고 싶습니다.

## 출처

1. [Brynjolfsson, Li & Raymond, Generative AI at Work, QJE 140(2), 2025](https://doi.org/10.1093/qje/qjae044)
2. [Satya Nadella, Introducing CoreAI: Platform and Tools (2025-01-13)](https://blogs.microsoft.com/blog/2025/01/13/introducing-core-ai-platform-and-tools/)
3. [Microsoft, Agents, human agency, and the opportunity for every organization (2026-05-05)](https://www.microsoft.com/en-us/worklab/work-trend-index/agents-human-agency-and-the-opportunity-for-every-organization)
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
