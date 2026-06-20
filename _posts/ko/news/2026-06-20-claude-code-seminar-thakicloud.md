---
title: "우리가 Claude Code를 직접 가르치는 이유: ThakiCloud 사내 세미나 자료 공개"
excerpt: "환경설정부터 놓치기 쉬운 기능까지. ThakiCloud 개발팀이 Claude Code를 내재화한 과정과 세미나 자료 전체를 공개합니다."
seo_title: "ThakiCloud Claude Code 사내 세미나 자료 공개 - 개발자 생산성 내재화"
seo_description: "ThakiCloud 개발팀이 운영한 Claude Code 사내 세미나 자료를 공개합니다. 환경설정, 핵심 명령어, 마스터하기, 놓치기 쉬운 기능까지 실무 중심으로 정리한 슬라이드와 녹화 영상."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - news
tags:
  - claude-code
  - seminar
  - developer-productivity
  - thakicloud
  - ai-tooling
  - internal-training
  - agentic-coding
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/news/claude-code-seminar-thakicloud/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 6분

![Claude Code 세미나](/assets/images/claude-code-seminar-hero.png)

AI 코딩 도구를 도입하는 팀은 많다. 그런데 그 도구를 팀 전체가 제대로 쓰는 팀은 훨씬 적다. ThakiCloud는 Claude Code를 단순히 설치하는 것으로 끝내지 않았다. 직접 세미나를 열어 환경설정부터 실무 활용 패턴까지 다듬었고, 그 자료를 오늘 공개한다.

## 왜 사내 세미나를 만들었나

Claude Code는 터미널에서 돌아가는 AI 코딩 에이전트다. 코드를 읽고, 파일을 수정하고, 테스트를 돌리고, git 커밋까지 처리한다. 기능 자체는 강력하지만, 처음 접하는 개발자 입장에서는 진입장벽이 있다. 어느 설정 파일이 어디에 있는지, 어떤 슬래시 커맨드가 실제로 유용한지, 어느 시점에 서브에이전트를 써야 하는지 같은 것들은 공식 문서만 읽어서는 감이 잡히지 않는다.

ThakiCloud 개발팀은 K8s 기반 AI SaaS 플랫폼을 운영하면서 Claude Code를 주력 도구로 쓰기 시작했다. 자연스럽게 "같이 배우고 같이 쓰자"는 흐름이 생겼고, 그게 세미나로 이어졌다.

목표는 두 가지였다. 하나는 팀원 모두가 같은 출발선에서 시작하는 것. 다른 하나는 각자 발견한 팁을 모아서 팀 전체의 생산성을 올리는 것.

## 세미나에서 다룬 내용

### 1. 환경설정 (Claude-Code-환경설정&명령어)

가장 먼저 다룬 것은 설정이다. Claude Code는 `~/.claude/` 아래에 설정 파일을 두는데, 이 구조를 이해하지 못하면 프로젝트마다 같은 설정을 반복하거나 충돌이 생긴다.

세미나에서는 `CLAUDE.md`의 역할부터 짚었다. 이 파일은 에이전트에게 프로젝트 컨텍스트를 알려주는 핵심 문서다. 어떤 스택을 쓰는지, 어떤 규칙을 따르는지, 어떤 커맨드가 있는지 여기에 정리해두면 매번 설명하지 않아도 된다. ThakiCloud에서는 Go + React 19 스택, 커밋 컨벤션, 자주 쓰는 make 커맨드를 모두 이 파일로 관리하고 있다.

MCP 서버 설정도 중요한 부분이었다. Slack, GitHub, Google Calendar, HuggingFace 같은 외부 서비스와 연결할 때 어떤 토큰이 필요하고 어디에 넣어야 하는지, 설정 오류가 생겼을 때 어디서 확인하는지 실습 중심으로 진행했다.

슬래시 커맨드도 이 세션에서 다뤘다. `/review`, `/debug`, `/compact` 같은 기본 커맨드부터 프로젝트 전용 커맨드를 `.claude/commands/`에 만드는 방법까지 포함했다.

### 2. Claude Code 마스터하기 (Claude-Code-마스터하기)

환경설정을 마친 다음 단계는 "어떻게 하면 잘 쓸 수 있나"였다.

핵심 주제 중 하나는 컨텍스트 관리였다. 에이전트 세션이 길어질수록 컨텍스트 창이 차오르고 품질이 떨어진다. 40% 이하로 유지하는 습관, 적절한 타이밍에 `/compact`를 쓰는 방법, 세션 간 상태를 이어받는 방법을 다뤘다.

멀티에이전트 패턴도 중요한 내용이었다. 복잡한 작업을 여러 서브에이전트에게 나눠 주는 방식은 단순히 "여러 개를 동시에 돌린다"는 개념이 아니다. 어떤 작업에 어떤 모델 티어를 쓸지(탐색에는 haiku, 구현에는 sonnet, 아키텍처 결정에는 opus), 비용과 품질을 어떻게 균형 잡을지가 핵심이다.

Plan Mode도 다뤘다. Shift+Tab 두 번으로 들어가는 이 모드는 코드를 바로 건드리기 전에 에이전트가 계획만 세우게 강제한다. 데이터베이스 마이그레이션이나 API 계약 변경처럼 비가역적인 변경 전에 반드시 거쳐야 하는 단계다.

### 3. 놓치기 쉬운 기능 (Claude-Code-놓치기쉬운기능)

마지막 세션은 실제로 쓰다 보면 놓치기 쉬운 기능들을 모았다.

Hooks가 대표적이다. 에이전트가 멈출 때, 특정 도구를 실행하기 전후에 스크립트를 자동으로 실행할 수 있다. ThakiCloud에서는 이 기능으로 KB(지식 베이스) 컴파일이나 스킬 라우터 게이트 같은 자동화를 만들었다.

키보드 단축키도 익혀두면 속도 차이가 크다. Esc-Esc로 마지막 턴을 되돌리는 `/rewind`, 이전 대화 내용을 불러오는 `Ctrl+R` 같은 것들이다.

`ultrathink` 키워드로 extended thinking을 최대로 켜는 방법, 프롬프트 캐싱을 깨지 않도록 시스템 프롬프트를 안정적으로 유지하는 방법도 이 세션에 담겼다.

RTK(rtk prefix로 터미널 출력을 60~90% 압축하는 CLI)처럼 Claude Code와 함께 쓰면 효과가 배가되는 도구들도 소개했다.

## 세미나 자료 다운로드

아래 자료를 자유롭게 열람하고 팀 내 활용에 참고할 수 있다.

| 자료 | 형식 | 링크 |
|------|------|------|
| Claude Code 마스터하기 | PPTX | [슬라이드 열기](https://drive.google.com/file/d/1U-wkk1dy-HZL7Ub4vwvLtb78RRdI_LF3/view) |
| Claude Code 세미나 전체 자료 | PDF | [PDF 열기](https://drive.google.com/file/d/1ZmedC8GkU2oJKsex2n45q12Owehx10yk/view) |
| 놓치기 쉬운 기능 (녹화) | MP4 | [영상 보기](https://drive.google.com/file/d/1-sDTY8r0w-yUWDd-Ow1QSQmvibaeLKEc/view) |

> 환경설정 녹화 파일은 현재 재업로드 중이다. 준비되면 이 글에 추가할 예정.

## AI 도구 내재화를 채용 시그널로 보는 이유

ThakiCloud는 AI 코딩 도구를 단순히 "도입한" 팀이 아니다. 직접 가르치고, 자체 스킬을 만들고, 팀 전체의 워크플로에 엮는 팀이다.

이 글을 쓰는 시점 기준으로 ThakiCloud의 `.claude/skills/` 디렉토리에는 스킬이 수백 개 들어 있다. 코드 리뷰, 인프라 배포, 마케팅 콘텐츠 생성, 특허 초안 작성, 주식 분석까지 실제 업무 흐름을 자동화한 스킬들이다. 이 스킬들은 Claude Code 위에서 동작하고, 세미나를 통해 팀원 모두가 이 시스템을 이해하고 기여할 수 있다.

개발자 입장에서 ThakiCloud에 합류한다는 것은 AI 도구를 쓸 수 있다는 것 이상의 의미가 있다. 그 도구가 어떻게 구성되어 있는지 이해하는 팀, 더 잘 쓰기 위해 계속 실험하는 팀과 함께 일하게 된다는 뜻이다.

세미나 자료가 다른 팀에게도 도움이 되길 바란다. 질문이나 피드백이 있으면 언제든지.
