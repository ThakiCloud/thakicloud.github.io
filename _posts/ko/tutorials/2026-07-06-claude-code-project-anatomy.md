---
title: "Claude Code 프로젝트 제대로 세팅하기: .claude/ 폴더 해부"
excerpt: "대부분의 개발자는 세팅을 건너뛰고 바로 프롬프트를 칩니다. 그게 실수입니다. CLAUDE.md·rules·commands·skills·agents·hooks로 이어지는 .claude/ 폴더의 구조를, 스킬 1,671개가 도는 실제 프로덕션 프로젝트를 직접 측정해 뜯어봅니다. ThakiCloud가 이 패턴을 Agent-Native Cloud 'Paxis'로 제품화한 방식과 연결합니다."
tags:
  - claude-code
  - developer-experience
  - agent-native
  - paxis
  - agentops
date: 2026-07-06
lang: ko
canonical_url: "https://thakicloud.github.io/ko/tutorials/claude-code-project-anatomy/"
categories:
  - tutorials
---

![층층이 쌓인 설정 레이어가 하나의 정돈된 에이전트 실행으로 수렴하는 추상 이미지](/assets/images/claude-code-project-anatomy-hero.webp)
*흩어진 지시·규칙·도구가 폴더 구조로 정리되면 에이전트의 행동이 예측 가능해집니다.*

## 개요

Claude Code로 작업을 시작할 때 가장 흔한 실수는 세팅을 건너뛰고 바로 프롬프트부터 치는 것입니다. 몇 번은 잘 되지만, 프로젝트가 커지면 같은 지시를 매번 반복하게 되고, 모델은 매 세션 백지에서 다시 시작합니다. 결과의 품질이 프롬프트 실력이 아니라 그날의 운에 좌우되기 시작합니다.

이 문제의 해법은 모델을 더 좋은 것으로 바꾸는 게 아니라 **프로젝트 자체를 하나의 계약 구조로 만드는 것**입니다. Claude Code에서 그 계약이 사는 곳이 바로 프로젝트 루트의 `.claude/` 폴더입니다. 최근 X에서 널리 공유된 Akshay Pachaar의 ".claude/ 폴더 해부" 스레드가 이 구조를 잘 정리했는데, 이 글에서는 그 뼈대를 따라가되 **실제로 스킬 1,671개가 도는 프로덕션 Claude Code 프로젝트를 직접 측정한 수치**로 각 레이어가 현실에서 어떤 규모로 쓰이는지 보여 드립니다. 그리고 ThakiCloud가 이 패턴을 Agent-Native Cloud인 Paxis로 제품화한 방식과 연결합니다.

## .claude/ 폴더는 무엇인가

`.claude/`는 Claude Code에게 "이 프로젝트에서는 이렇게 일하라"고 알려 주는 규약의 집합입니다. 핵심은 하나의 거대한 프롬프트가 아니라, 역할이 다른 여러 레이어로 나뉘어 있다는 점입니다. 각 레이어는 로딩 시점과 비용이 다릅니다.

```mermaid
flowchart TB
    A[.claude/ 프로젝트 루트] --> B[CLAUDE.md<br/>프로젝트 브레인]
    A --> C[rules/<br/>상시 규칙]
    A --> D[commands/<br/>반복 워크플로]
    A --> E[skills/<br/>온디맨드 전문지식]
    A --> F[agents/<br/>격리 서브에이전트]
    A --> G[settings.json<br/>권한·훅]
    B --> B1[매 세션 자동 로드]
    C --> C1[매 턴 자동 로드]
    E --> E1[요청이 트리거할 때만 로드]
    F --> F1[Agent 도구로 소환]
    G --> G1[PreToolUse·PostToolUse·Stop 등]
```

각 레이어의 역할을 나누면 이렇습니다.

**CLAUDE.md**는 프로젝트의 브레인입니다. 매 세션 자동으로 로드되며, 아키텍처 개요·기술 스택·컨벤션·워크플로 규칙 네 가지에만 답합니다. 여기에 "가끔만 필요한" 지식을 다 밀어 넣으면 매 세션 컨텍스트를 낭비하게 됩니다. 그래서 CLAUDE.md는 얇게 유지하는 것이 원칙입니다.

**rules/**는 매 턴 적용되는 상시 규칙입니다. 코딩 스타일·보안 정책·git 워크플로·품질 게이트처럼 모든 작업에 걸리는 불변 규칙을 둡니다. CLAUDE.md가 비대해지면 이쪽으로 쪼갭니다.

**commands/**는 반복 워크플로를 슬래시 커맨드로 묶어 둔 것입니다. `/review`나 `/ship` 같은 명령 하나로 정해진 다단계 절차를 부릅니다.

**skills/**는 요청이 트리거할 때만 로드되는 온디맨드 전문지식입니다. 항상 필요하지는 않은 도메인 파이프라인·분석 레시피를 여기에 둡니다. 스킬은 인덱스에 이름과 설명만 올라가 있다가, 관련 요청이 오면 본문이 로드됩니다.

**agents/**는 독립적인 역할·도구·모델을 가진 전문가 정의입니다. Agent 도구로 소환하며, 탐색은 저렴한 모델로, 구현은 균형 모델로, 아키텍처 판단은 강한 모델로 라우팅합니다.

**settings.json**은 권한과 훅을 잠급니다. 훅은 도구 호출 전후(`PreToolUse`/`PostToolUse`)나 세션 종료 시(`Stop`) 결정론적 코드를 끼워 넣어, 모델이 아니라 코드가 포맷·검증을 소유하게 만듭니다.

여기에 더해 `.claude/` 폴더는 두 벌이 존재합니다. 하나는 리포지토리에 커밋되어 팀 전체가 공유하는 프로젝트용이고, 다른 하나는 `~/.claude/`에 있는 전역 폴더로 개인 선호와 프로젝트 간 자동 메모리를 담습니다.

## 설치 및 구성

가장 빠른 시작은 프로젝트 루트에서 초기화하는 것입니다.

```bash
# 프로젝트 루트에서
claude
# 세션 안에서 프로젝트 브레인 초안 생성
/init
```

`/init`은 리포지토리를 훑어 `CLAUDE.md` 초안을 만들어 줍니다. 이후에는 수동으로 정제합니다. 폴더 골격은 다음과 같이 손으로 만들어도 됩니다.

```bash
mkdir -p .claude/rules .claude/commands .claude/skills .claude/agents .claude/hooks
```

`settings.json`에 훅을 배선하는 예시입니다. 편집 후 자동 포맷을 거는 PostToolUse 훅입니다.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "python3 .claude/hooks/format-on-save.py",
        "description": "편집한 파일 자동 포맷"
      }
    ]
  }
}
```

스킬 하나의 최소 형태는 `SKILL.md` 프론트매터입니다. `description`이 검색 트리거가 되므로 영문·한글 키워드를 함께 넣고, 인접 스킬과 헷갈리지 않도록 "쓰지 말아야 할 경우"까지 적습니다.

```yaml
---
name: my-pipeline
description: >-
  Does X in one sentence. Use when <english + 한글 trigger phrases>.
  Do NOT use for <anti-pattern> (use other-skill).
---
```

핵심 규율은 하나입니다. **능력은 하네스가 아니라 스킬에 쌓습니다.** CLAUDE.md와 rules는 얇게 유지하고, 도메인 지식·판단·템플릿·실패 사례는 스킬에 두텁게 넣습니다. 같은 스킬이 Claude Code든 다른 하네스든 가로질러 동작하도록 만드는 것이 목표입니다.

![CLAUDE.md는 얇게, 능력은 스킬에 쌓는 원칙을 저울로 표현한 슬라이드](/assets/images/claude-code-project-anatomy-slide-05.png)

## 실제 측정: 프로덕션 Claude Code 프로젝트의 해부

![1,671개의 스킬이 증명하는 설계 원칙, 프로덕션 환경의 데이터 해부 슬라이드](/assets/images/claude-code-project-anatomy-slide-06.png)

이 글을 쓰는 리포지토리 자체가 무겁게 구성된 Claude Code 프로젝트입니다. 각 레이어가 현실에서 어떤 규모로 쓰이는지, 직접 파일을 세어 측정했습니다. 아래 수치는 모두 실제 측정값입니다.

| 레이어 | 실측 개수 | 로딩 시점 | 역할 |
|---|---|---|---|
| CLAUDE.md | 94줄 | 매 세션 | 프로젝트 브레인 (얇게 유지) |
| rules/ | 49개 | 매 턴 | 상시 규칙 |
| commands/ | 22개 | 호출 시 | 반복 워크플로 |
| skills/ | 1,671개 | 트리거 시 | 온디맨드 전문지식 |
| agents/ | 60개 | 소환 시 | 격리 서브에이전트 |
| hooks/ | 12개 | 도구 전후 | 결정론적 게이트 |

여기서 드러나는 설계 원칙이 명확합니다. CLAUDE.md는 94줄로 매우 얇습니다. 매 세션 로드되는 파일이므로 "임대료"를 내는 셈이고, 그래서 최소한만 담습니다. 반면 스킬은 1,671개로 압도적으로 많습니다. 스킬은 트리거될 때만 로드되므로, 이렇게 방대해도 매 턴 비용을 물리지 않습니다.

측정된 훅 이벤트는 `PreToolUse`, `PostToolUse`, `Stop`, `SessionStart`, `UserPromptSubmit` 다섯 종이었고, `settings.json`은 `permissions`·`hooks`·`env` 세 축으로 구성되어 있었습니다. 즉 항상 켜져 있는 것(rules·hooks)은 소수로 억제하고, 필요할 때만 부르는 것(skills·agents)은 크게 늘리는 구조입니다.

그런데 스킬이 1,671개나 되면 새로운 문제가 생깁니다. 사람도, 모델도 이 목록 전체를 훑어 "지금 어떤 스킬을 써야 하는지" 고를 수 없습니다. 이 지점이 정확히 다음 섹션으로 이어집니다.

## ThakiCloud 제품 적용 시사점

스킬이 수천 개가 되는 순간, `.claude/` 폴더의 파일 관리는 더 이상 개인의 정리 문제가 아니라 **런타임 라우팅 문제**가 됩니다. ThakiCloud는 이 패턴을 Agent-Native Cloud인 **Paxis**로 제품화했습니다.

Paxis는 ThakiCloud의 AI 인프라(ai-platform) 위에서 도는 에이전트 제어 평면으로, Skills·Tools·Policies·Audit Logs를 일급 리소스로 다룹니다. `.claude/` 폴더 해부와 직접 맞닿는 부분은 **Skill Harness**입니다. 위에서 본 것처럼 스킬을 아무리 많이 만들어도, 매 턴 전부 로드하면 컨텍스트가 폭발합니다. Paxis는 요청이 들어오면 방대한 스킬 풀에서 BM25 검색으로 관련 스킬만 선택해 로드하고, 그 스킬을 격리된 샌드박스에서 실행합니다. 이 글의 실측처럼 스킬 수가 1,000개를 훌쩍 넘어도 라우팅이 성립하는 이유입니다.

![1,671개 스킬을 BM25로 검색해 관련 스킬만 격리 샌드박스에서 실행하는 Paxis 라우팅 엔진 슬라이드](/assets/images/claude-code-project-anatomy-slide-11.png)

여기에 hooks가 하는 일(결정론적 게이트)을 정책 게이트와 감사 로그로 승격합니다. `.claude/settings.json`의 PreToolUse 훅이 위험한 명령을 막듯, Paxis는 모든 에이전트 행동을 정책 게이트와 감사 로그로 통과시켜 "누가 언제 무엇을 실행했는가"를 남깁니다. 개인 프로젝트의 훅을 멀티테넌트 환경에서도 신뢰할 수 있게 만든 형태입니다.

agents/ 레이어는 Paxis의 DAG 멀티에이전트 오케스트레이션으로 이어집니다. 개별 서브에이전트를 역할·모델별로 분리하는 로컬 패턴이, 여러 에이전트를 의존성 그래프로 묶어 병렬 실행하고 검증 단계로 닫는 구조로 확장됩니다.

인프라 관점(ai-platform 렌즈)에서도 의미가 있습니다. 이 모든 스킬·에이전트 실행은 결국 GPU와 추론 비용을 소모합니다. ThakiCloud의 ai-platform은 K8s·Kueue 기반 GPU 스케줄링과 vLLM 서빙으로 이 실행을 낮은 비용에 받쳐 주며, 온프렘·소버린 요구가 있는 고객 환경에서도 같은 하네스를 self-hosting으로 돌릴 수 있게 합니다. 저비용 서빙이 에이전트 경제성을 만들고, 그 위에서 Paxis의 스킬 하네스가 돌아가는 구조입니다.

![K8s·Kueue GPU 스케줄링과 vLLM 서빙으로 에이전트 실행을 낮은 비용에 받치는 ai-platform 인프라 슬라이드](/assets/images/claude-code-project-anatomy-slide-13.png)

## 한계 및 반론

이 접근이 항상 정답은 아닙니다. 첫째, 작은 스크립트나 일회성 작업에 무거운 `.claude/` 구조를 강제하는 것은 과잉입니다. rules 하나를 추가하기 전에 "이게 정말 매 턴 필요한가"를 물어야 하고, 아니라면 스킬로 내려야 합니다. 세팅 자체가 목적이 되면 안 됩니다.

둘째, 스킬을 수천 개까지 늘리면 검색 노이즈가 새로운 병목이 됩니다. 이름이 비슷한 스킬이 많아질수록 라우팅 정확도가 떨어지고, 엉뚱한 스킬이 로드될 위험이 커집니다. 이 문제는 모델 등급을 올린다고 풀리지 않으며, 스킬 설명(description)의 트리거·경계를 다듬는 지루한 작업으로만 개선됩니다.

셋째, 커밋되는 `.claude/` 폴더에는 팀 공유 설정만 넣고, 개인 경로·토큰·디버깅 단축키는 `~/.claude/`나 `CLAUDE.local.md`에 두어야 합니다. 이 경계를 지키지 않으면 개인 정보가 리포지토리에 노출됩니다.

정리하면, `.claude/` 폴더 세팅은 "모델을 더 좋게 만드는" 일이 아니라 "모델의 행동을 예측 가능하게 만드는" 일입니다. 프로젝트가 작을 때는 CLAUDE.md 한 장으로 충분하고, 커질수록 rules·skills·agents·hooks로 쪼개면 됩니다. 그리고 스킬이 수천 개 규모로 커지는 순간, 그것은 더 이상 폴더 정리가 아니라 라우팅 인프라의 문제가 됩니다. Paxis는 바로 그 지점을 제품으로 다룹니다.

## 출처

- [Akshay Pachaar, "How to setup your Claude code project?" (X)](https://x.com/akshay_pachaar/status/2035706568142893229)
- [Builder.io, "Setting Up a New Claude Code Project: The Complete Guide"](https://www.builder.io/blog/setting-up-claude-code-project)
- [Claude Code Docs: Quickstart](https://code.claude.com/docs/en/quickstart)
