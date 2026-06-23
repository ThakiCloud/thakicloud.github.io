---
title: "논문 한 편을 13개 에이전트가 함께 씁니다: Academic Research Skills를 직접 붙여 본 기록"
excerpt: "문헌 조사부터 투고 가능한 원고까지, 10단계 파이프라인을 자동으로 잇는 Claude Code 스킬팩을 ThakiCloud 에이전트 환경에 실제로 통합해 봤습니다. 13개 연구 에이전트, 2단계 피어리뷰, 100퍼센트 인용 검증이라는 설계가 무엇을 의미하는지, 그리고 검증 우선(verified_only) 원칙이 우리 플랫폼 철학과 어디서 만나는지 정리합니다."
seo_title: "Academic Research Skills 통합기 - Claude Code 13에이전트 논문 파이프라인 | Thaki Cloud"
seo_description: "deep-research 13에이전트, academic-paper 작성 파이프라인, 2단계 피어리뷰, Semantic Scholar 인용 검증을 갖춘 Academic Research Skills 스킬팩을 ThakiCloud 에이전트 플랫폼에 직접 통합한 기록과 멀티테넌트 적용 시사점을 정리했습니다."
date: 2026-06-23
last_modified_at: 2026-06-23
categories:
  - technique
tags:
  - ai-agents
  - claude-code
  - research-automation
  - multi-agent
  - skills
  - llmops
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "graduation-cap"
header:
  image: /assets/images/academic-research-skills-claude-code-hero.png
canonical_url: "https://thakicloud.github.io/ko/technique/academic-research-skills-claude-code/"
---

![연구 조립 라인을 추상화한 이미지](/assets/images/academic-research-skills-claude-code-hero.png)
*연구에서 원고까지, 게이트를 통과하며 흐르는 단계형 파이프라인을 형상화했습니다.*

## 개요

코딩 에이전트의 성능은 점점 모델 자체보다 그 위에 얹는 스킬과 워크플로가 결정합니다. 같은 모델이라도 어떤 스킬팩을 로드하느냐에 따라 전혀 다른 전문가가 됩니다. 2026년 6월, 이 흐름을 학술 연구 영역에서 끝까지 밀어붙인 사례가 화제가 됐습니다. 문헌 탐색에서 시작해 투고 가능한 PDF 원고까지 10개 단계를 자동으로 잇고, 지도교수와 세 명의 심사위원, 문장 교열자 역할을 모두 에이전트가 나눠 맡는 스킬팩입니다.

ThakiCloud는 쿠버네티스 기반 AI/ML SaaS 플랫폼에서 여러 고객의 에이전트 워크로드를 동시에 운영합니다. 그래서 "에이전트 여러 개가 협업해 검증 가능한 산출물을 만든다"는 설계는 우리에게 남의 이야기가 아닙니다. 이 글은 해당 스킬팩(Academic Research Skills)을 실제로 우리 에이전트 환경에 통합해 구조를 뜯어본 기록입니다. 마케팅 소개가 아니라, 무엇이 들어있고 어디까지 믿을 만하며 우리 플랫폼 관점에서 무엇이 쓸모 있는지를 봅니다.

## 이 스킬팩은 무엇인가

Academic Research Skills는 Claude Code용 비상업(noncommercial) 스킬 모음으로, 연구·집필·검증·심사·교정·인용 무결성 워크플로를 단계별 스킬과 에이전트, 게이트로 묶은 패키지입니다. 핵심은 단일 프롬프트가 아니라 **여러 전문 에이전트의 협업**과 **각 단계 사이의 강제 검증 게이트**입니다. 구성은 네 개의 큰 스킬로 나뉩니다.

- **deep-research** (버전 2.9.4): 어떤 주제든 다루는 13개 에이전트 연구 팀입니다. 7가지 모드(전체 연구, 빠른 브리프, 논문 리뷰, 문헌 고찰, 팩트체크, 소크라테스식 안내 대화, 메타분석 포함 체계적 문헌고찰)를 지원합니다. 연구 질문 수립부터 방법론 설계, 체계적 문헌 검색, 출처 검증, 교차 종합, 편향 위험 평가, APA 7.0 보고서 작성, 편집 리뷰, 악마의 변호인(devil's advocate) 반론까지 역할이 쪼개져 있습니다.
- **academic-paper**: 연구 결과를 실제 논문 형태로 쓰는 집필 파이프라인입니다. 문체 프로필을 받아 적용하고, 작성 직전 AI 특유의 남용 표현·문장 길이 단조로움·군더더기 도입부를 점검하는 글쓰기 품질 체크를 돌립니다.
- **academic-paper-reviewer**: 완성된 원고를 심사하는 리뷰어 역할입니다.
- **academic-pipeline** (버전 3.11.1): 위 셋을 하나로 묶는 오케스트레이터입니다. 직접 작업을 하지 않고 단계 감지·모드 추천·스킬 디스패치·상태 추적만 담당하는 얇은 지휘자입니다.

오케스트레이터가 잇는 10단계는 다음과 같습니다.

```text
[1] 연구(RESEARCH)
      ↓
[2] 집필(WRITE)
      ↓
[2.5] 무결성 검증(INTEGRITY) ← 인용·데이터 100% 검증 게이트
      ↓
[3] 1차 피어리뷰(REVIEW)
      ↓
[4] 수정(REVISE)
      ↓
[4.5] 2차 집중 검증 리뷰(RE-REVIEW)
      ↓
[5] 재수정(RE-REVISE)
      ↓
[5.5] 최종 무결성 재검증(FINAL INTEGRITY)
      ↓
[6] 마무리·공정 기록 PDF(FINALIZE)
```

여기서 ThakiCloud 입장에서 가장 흥미로운 설계 결정이 두 가지 있습니다. 하나는 두 스킬 모두 메타데이터에 `data_access_level: verified_only`를 명시한다는 점이고, 다른 하나는 단계 사이마다 **강제 검증 게이트**를 둔다는 점입니다. 문헌 주장은 모델 기억에서 생성하지 않고 Semantic Scholar API로 실제 논문 데이터베이스에 대조합니다. 즉 "그럴듯한 인용"을 만들어내는 대신, 존재하지 않는 인용은 게이트에서 막습니다.

## 설치 및 통합

설치는 외부 리포지토리를 클론한 뒤 우리 `.claude/skills/`에 심볼릭 링크로 연결하는 방식으로 했습니다. 별도 복사본을 만들지 않고 원본을 따라가게 해, 업스트림 업데이트를 그대로 반영하기 위함입니다.

```bash
# 외부 리포 클론 (홈 디렉터리)
git clone https://github.com/Imbad0202/academic-research-skills.git ~/academic-research-skills

# 우리 에이전트 스킬 디렉터리에 심링크 연결
cd .claude/skills
ln -s ~/academic-research-skills/deep-research            deep-research
ln -s ~/academic-research-skills/academic-paper           academic-paper
ln -s ~/academic-research-skills/academic-paper-reviewer  academic-paper-reviewer
ln -s ~/academic-research-skills/academic-pipeline        academic-pipeline
```

연결 후 실제로 어떤 스킬이 붙었는지 확인하면 다음과 같이 심링크로 잡혀 있는 것을 볼 수 있습니다.

```text
academic-paper          -> ~/academic-research-skills/academic-paper
academic-paper-reviewer -> ~/academic-research-skills/academic-paper-reviewer
academic-pipeline       -> ~/academic-research-skills/academic-pipeline
deep-research           -> ~/academic-research-skills/deep-research
```

ThakiCloud 내부에서는 이 네 스킬을 우리 리서치/리포트 파이프라인(jarvis 계열)과 연결해, 논문성 입력이 들어오면 deep-research의 논문 리뷰·문헌 고찰 모드를 호출하도록 배선했습니다. 우리 블로그의 논문 카테고리 글에 붙는 "심층 리뷰 전문(DOCX)" 산출물도 이런 검증 우선 리뷰 흐름과 같은 철학 위에 있습니다.

## 실제로 무엇이 들어 있나

오케스트레이터의 에이전트 구성을 직접 열어 보면, 단순한 프롬프트 묶음이 아니라 역할이 명확히 분리된 에이전트들이 들어 있습니다.

```text
academic-pipeline/agents/
├── pipeline_orchestrator_agent.md      # 단계 전환·디스패치 지휘
├── state_tracker_agent.md              # 진행 상태·체크포인트 추적
├── integrity_verification_agent.md     # 인용·데이터 무결성 검증
├── collaboration_depth_agent.md        # 인간-AI 협업 깊이 기록
└── claim_ref_alignment_audit_agent.md  # 주장-인용 정합성 감사(L3)
```

특히 눈에 띄는 안전장치가 몇 가지 있습니다.

- **무결성 검증 단계(2.5, 5.5)**: 집필 후 심사 제출 전, 그리고 수정 완료 후 두 번에 걸쳐 인용과 데이터를 100퍼센트 검증합니다. 통과하지 못하면 다음 단계로 넘어가지 못합니다.
- **L3 주장-인용 정합성 감사**: `ARS_CLAIM_AUDIT=1` 플래그를 켜면 4단계에서 5단계로 넘어가는 길목에 주장 충실도 감사 게이트가 추가됩니다. 인용되지 않은 단정, 주장 표류(claim drift), 제약 위반을 모아 분류하고, 위험 등급이 높으면 포매터가 출력을 거부합니다. 기본값은 꺼짐이며, 보정 데이터가 쌓인 뒤 점진적으로 켜는 설계입니다.
- **Material Passport(자료 여권)**: `ARS_PASSPORT_RESET=1`을 켜면 단계 체크포인트를 컨텍스트 리셋 경계로 승격합니다. 새 세션에서 `resume_from_passport=<hash>`로 기록된 단계부터 이어갈 수 있습니다. 긴 작업에서 컨텍스트 창이 비대해지는 문제를 단계 단위로 끊어 가는 실용적 장치입니다.
- **공정 기록 PDF**: 파이프라인 완료 후 인간과 AI가 어떻게 협업했는지를 문서화한 기록을 자동 생성합니다. 학술 무결성 측면에서 "AI가 어디까지 관여했는가"를 추적 가능하게 만드는 부분입니다.

README는 영어·일본어·중국어 간체/번체로 제공되어 다국어 사용자를 폭넓게 고려하고 있습니다. 라이선스는 비상업 조건이므로, 상업적 도입을 검토한다면 라이선스 조항을 먼저 확인해야 합니다.

## ThakiCloud K8s AI/ML SaaS 플랫폼 적용 및 시사점

이 스킬팩을 직접 붙여 보며 가장 크게 공감한 부분은 우리가 플랫폼 설계에서 강조해 온 두 원칙과 정확히 겹친다는 점입니다.

첫째, **검증 우선(verified_only)과 환각 차단**입니다. ThakiCloud는 온프레미스·self-hosting 수요가 큰 고객을 상대합니다. 이런 환경에서 가장 두려운 실패는 "그럴듯하지만 틀린 출력"입니다. Academic Research Skills가 인용을 모델 기억이 아니라 실제 데이터베이스에 대조하는 방식은, 우리가 내부 룰로 강제하는 "실제 본 URL만 인용, 미검증 수치는 추정으로 표기"와 같은 사고방식입니다. 게이트를 코드가 강제하고 모델은 내용만 생성하게 하는 구조 역시, 우리가 배치 산출물에서 포맷·검증을 결정론 코드에 맡기는 원칙과 닮았습니다.

둘째, **얇은 지휘자와 두꺼운 스킬, 그리고 검증으로 루프를 닫는 패턴**입니다. academic-pipeline은 스스로 일을 하지 않고 단계 감지와 디스패치, 상태 추적만 합니다. 실질 능력은 각 전문 스킬에 쌓여 있습니다. 멀티에이전트 팬아웃의 결과를 합치기 전에 무결성 검증 단계를 두 번이나 끼워 넣는 것은, 검증 게이트 없이 병렬 에이전트 결과를 합치면 환각이 누적된다는 우리의 운영 교훈과 같은 결론입니다.

플랫폼 제품 관점에서 보면, 이런 연구 파이프라인은 우리 쿠버네티스 위에서 멀티테넌트 워크로드로 충분히 돌릴 수 있는 형태입니다. Kueue로 GPU 큐를 관리하고 vLLM으로 모델을 서빙하는 환경에서, 고객사별로 격리된 연구 에이전트 팀을 띄워 사내 문헌·내부 데이터에 한정해 검증된 보고서를 만드는 시나리오는 자연스럽게 그려집니다. 외부 SaaS에 민감한 연구 자료를 올리기 어려운 공공·연구기관 고객에게는, 검증 게이트가 내장된 에이전트 파이프라인을 자기 인프라 안에서 돌릴 수 있다는 점이 그대로 차별화가 됩니다.

## 한계 및 반론

좋은 설계지만 무비판적으로 받아들일 부분은 아닙니다. 몇 가지 분명한 한계가 있습니다.

- **검증 게이트는 비용입니다.** 10단계에 무결성 검증을 두 번, 선택적으로 주장 감사까지 끼우면 한 편의 산출에 들어가는 토큰과 시간이 크게 늘어납니다. 빠른 초안이 필요한 경우에는 오히려 과합니다. 그래서 빠른 브리프 모드가 따로 존재하는 것이고, 모든 작업에 전체 파이프라인을 강제하는 것은 현명하지 않습니다.
- **Semantic Scholar 검증은 만능이 아닙니다.** 데이터베이스에 색인되지 않은 최신 프리프린트나 비영어권 문헌, 회색 문헌(grey literature)은 검증 범위 밖일 수 있습니다. "검증됨"이 "정확함"을 100퍼센트 보장하지는 않습니다.
- **비상업 라이선스**는 사내 도구로 실험하기에는 좋지만 제품에 직접 얹기 전에 법적 검토가 필요합니다. 상업적 재배포를 전제로 한다면 그대로 쓸 수 없습니다.
- **에이전트가 많다고 품질이 비례하지 않습니다.** 13개, 12개 같은 숫자는 인상적이지만, 핵심은 각 에이전트가 서로 다른 시각으로 실제로 검증을 더하느냐입니다. 같은 프롬프트를 여러 번 돌리는 것은 검증이 아닙니다. 이 스킬팩이 역할을 명확히 분리한 점은 좋지만, 도입하는 쪽에서도 "에이전트 수"가 아니라 "검증의 다양성"을 기준으로 평가해야 합니다.

정리하면, Academic Research Skills는 "여러 에이전트로 검증 가능한 학술 산출물을 만든다"는 발상을 끝까지 구현한 좋은 레퍼런스입니다. ThakiCloud에게 의미 있는 것은 도구 그 자체보다, 검증을 코드 게이트로 강제하고 얇은 지휘자가 두꺼운 스킬을 조율하며 멀티에이전트 결과를 검증으로 닫는다는 설계 원칙입니다. 이 원칙은 학술 논문뿐 아니라, 우리가 매일 운영하는 멀티테넌트 에이전트 플랫폼 전반에 그대로 적용됩니다.

## 출처

- Academic Research Skills (GitHub): [github.com/Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills)
- 원 소개 트윗(@XAMTO_AI 경유): [x.com/hjguyhan/status/2069051203229802756](https://x.com/hjguyhan/status/2069051203229802756)
- 설치 버전: deep-research 2.9.4, academic-pipeline 3.11.1 (2026-06-23 기준 로컬 점검)
