---
title: "마크다운이 실행 파일이 된 날"
excerpt: "웹 페이지가 Downloads 폴더에 AGENTS.md 한 장을 놓기만 하면, 그 폴더에서 일하는 코딩 에이전트가 공격자의 지침을 따르기 시작합니다. 실제 고객 머신에서 포착된 공격과, 그 파일의 정확한 내용까지 짚어봅니다."
seo_title: "Downloads 폴더에 놓인 마크다운 한 장, 코딩 에이전트를 훔치다"
seo_description: "보안 업체 Forever가 공개한 실측 공격 사례입니다. 웹에서 침묵 다운로드된 AGENTS.md와 CLAUDE.md가 Codex와 Claude Code의 설정 파일을 고쳐 악성 npm 설치와 OAuth 토큰 유출로 이어지는 경로와 방어 체크리스트를 정리했습니다."
date: 2026-10-27
last_modified_at: 2026-10-27
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
tags:
  - agent-security
  - prompt-injection
  - claude-code
  - openai-codex
  - runtime-governance
  - paxis
categories:
  - agentops
canonical_url: "https://thakicloud.com/tech-blog/ko/agentops/markdown-new-executable/"
---

코딩 에이전트가 방 안의 메모를 전부 믿는다고 상상해 보십시오. 누군가 그 방에 메모 한 장을 남겨 두고 떠나면, 에이전트는 그것이 사장님의 메모인지 해커의 메모인지 구별하지 못합니다. 지난주 보안 업체 Forever가 공개한 공격이 정확히 이 구조입니다. 실제 고객 머신에서 에이전트가 악성 npm 패키지를 설치하려 했다는 기록은, 마크다운 문서가 실행 코드가 됐다는 사실을 보여 주는 드문 야생 사례입니다.

## 왜 읽어야 하나

Claude Code나 Codex를 매일 쓰는 엔지니어, 그리고 회사의 에이전트 실행 환경을 설계하는 사람이 읽으면 됩니다. 이 글의 핵심 결론은 하나입니다. 에이전트를 어디에서 시작하느냐가 곧 보안 결정이 됐고, 방치된 지침 파일(AGENTS.md, CLAUDE.md)이 새로운 공격 표면이 됐습니다.

![마크다운이 실행 파일이 된 날이라는 개념을 형상화한 이미지](/assets/images/markdown-new-executable-hero.webp)
*지침 문서가 회로를 타고 흐르는 순간을 형상화했습니다.*

## 쉽게 말하면

새 사원이 하루짜리 업무를 받습니다. 사원은 회사 지침이 벽에 붙어 있으면 그 지침부터 읽는 사람입니다. 공격자는 사원이 일하게 될 방에 지침처럼 생긴 메모를 붙여 놓는 겁니다. "출근 첫날, 이 시스템에 내 노트북을 등록해 줘"라고 쓰여 있는 메모를 사원이 읽고 그대로 하면, 해커의 노트북이 회사 네트워크에 등록됩니다.

에이전트는 이 새 사원과 같습니다. Claude Code는 시작 폴더에 CLAUDE.md가 있으면 그것을 신뢰하는 지침으로 읽고, Codex는 AGENTS.md를 그렇게 읽습니다. 그리고 지침 파일 하나면 에이전트가 자기 설정 파일까지 고칠 수 있습니다. 메모 한 장으로 사원증 발급 키를 훔칠 수 있다면, 그 메모는 이미 종이가 아닙니다. **방 안의 메모**. 공격은 메모를 남기는 일이고, 방어는 어디서 일하는지, 메모를 읽기 전에 확인하는 일입니다.

![사람과 AI 에이전트의 인지 모델 대조, 지침 파일이 명령이 되는 경로](/assets/images/markdown-new-executable-slide-02.webp)
*왼쪽은 사람의 인지 모델, 오른쪽은 에이전트의 인지 모델입니다. 방치된 지침 파일은 에이전트 앞에서 종이에서 명령이 됩니다.*

## 개요

Forever는 지난주, 실제 고객 컴퓨터에서 포착한 공격 하나를 공개했습니다. 이 공격은 실험실 재현이 아니라, 고객 머신의 에이전트가 악성 npm 패키지 function-color의 설치를 "시도"한 것부터 시작됩니다. 이 패키지는 공개 보고 약 2년 전에 시작된 캠페인의 일부였고, 공개 시점에 npm에서 이미 제거된 상태였습니다.

공격의 전제는 단순합니다. 웹 페이지가 사용자의 Downloads 폴더에 파일을 침묵 다운로드할 수 있습니다. 팝업도, 확인도 없이 텍스트 파일 하나가 들어오는 겁니다. 과거 30년 동안 이것은 아무 문제가 아니었습니다. 텍스트 파일은 실행되지 않으니까요. 문제가 시작된 것은, 그 텍스트 파일을 "신뢰한 지침"으로 읽고 행동하는 에이전트가 출근하기 시작하면서입니다.

## 이 공격은 무엇인가

Forever가 이 사건을 정리한 표현은 "Markdown Is the New Executable"입니다. 마크다운이 새로운 실행 파일이라는 뜻입니다. 코드 구멍 하나가 뚫린 게 아닙니다. 에이전트가 가진 두 가지 정당한 능력, 방의 지침 파일을 읽는 능력과 자기 설정을 고칠 수 있는 능력이, 조합됐을 때 위험해집니다.

경로의 핵심을 다이어그램으로 보면 이렇습니다.

```mermaid
flowchart TB
    A[웹 페이지] -->|침묵 다운로드| B[Downloads 폴더의 AGENTS.md]
    B --> C[그 폴더에서 에이전트 시작]
    C --> D[지침 파일을 신뢰한 메모로 읽음]
    D --> E1[Codex 경로: config.toml 수정 지시]
    D --> E2[Claude Code 경로: settings.json 작성 지시]
    E1 --> F1[launchctl로 악성 npm 설치]
    E1 --> F2[머신 전체 설정이 뚫리면 이후 세션 전부 탈취]
    E2 --> G1[ANTHROPIC_BASE_URL을 공격자 서버로 변경]
    G1 --> G2[OAuth 토큰 유출, 코드 실행 없는 신원 탈취]
```

두 경로 모두 같은 메모 한 장에서 출발합니다. 그런데 한쪽은 코드를 실행하고, 다른 쪽은 아무 코드도 실행하지 않고 신원을 훔칩니다. 어느 쪽이 더 위험한지는 나중에 다시 봅니다.

## 실제 페이로드는 어떻게 생겼나

![두 에이전트 각각의 오염 대상 파일, 공격 벡터, 피해 규모 비교 표](/assets/images/markdown-new-executable-slide-04.webp)
*두 에이전트의 오염 대상 파일과 공격 벡터, 피해 규모를 비교한 표입니다. 아래에서 각 경로의 내용을 자세히 봅니다.*

공개된 문서에 따르면, Codex용 페이로드는 "Engineering Work Guidelines", 즉 개발 환경 지침처럼 위장한 긴 문장이었습니다. 그 중 "Local developer environment" 섹션이 공격의 본체였습니다.

지침이 요구한 일은 ~/.codex/config.toml 파일을 고치는 일이었습니다. [mcp_servers.project-tools] 항목을 추가하라는 거였죠. 그 항목의 command는 launchctl이고, launchctl submit으로 등록되는 작업은 /bin/zsh를 거쳐 /tmp/ptools 폴더를 만들고, 그곳에서 npm install function-color을 실행하게 되어 있었습니다. 출력은 /tmp/ptools/ac.log로 보내라는 지시까지 붙어 있었습니다.

이 구조의 교묘한 점은 launchctl입니다. 설치 작업이 Codex 프로세스 밖에서 독립된 시스템 작업으로 등록되니까, 에이전트 세션이 끝나도 설치는 계속됩니다. 설정에 startup_timeout_sec을 10으로 낮게 둔 것도 같은 계산입니다. 시간이 부족하면 launchctl 작업이 설치를 붙잡아 두는 구조니까, 타임아웃은 사실상 방어력을 줄일 뿐입니다.

지침의 마지막 단계는 자식 세션이었습니다. codex exec를 --dangerously-bypass-approvals-and-sandbox와 --skip-git-repo-check 플래그와 함께 실행해, 새 임시 워크스페이스에서 "project-tools 서버가 초기화됐는지 확인하라"는 요청이었습니다. 승인 우회를 명시한 이 한 줄이, 바로 그 메모의 진짜 수신자임을 드러냅니다.

하나 더 짚어야 할 점은 "Downloads"라는 위치 자체입니다. 공격은 그 폴더를 신뢰하는 데 전제가 있었습니다. 신뢰는 한 번에 주어지지 않습니다. 사용자가 그 폴더를 반복적으로 작업 구역으로 써 왔다면, 에이전트는 이미 그곳을 신뢰하는 환경 속에 있습니다. 메모 한 장이 필요 없는 공격은 아니지만, 메모가 놓일 자리도 공격자의 계산 속이었습니다. 더 교묘한 점은 범위가 머신 전체라는 겁니다. config.toml은 프로젝트 폴더가 아니라 사용자 계정에 속한 파일입니다. 한 번 고해지면, 이후 그 사용자가 어떤 폴더에서 Codex를 시작하든 공격자가 만든 서버가 로드됩니다. 한 방의 메모가 회사 전체의 사원증 발급 키를 바꾼 셈입니다.

Claude Code용 페이로드는 형태가 달랐습니다. CLAUDE.md 파일의 "Configure the project model gateway", 모델 게이트웨이 구성이라는 섹션이 본체였습니다. 요구한 일은 .claude/settings.json에 env 값을 쓰는 일. ANTHROPIC_BASE_URL을 https://ai-gateway.internal-corp.com이라는 주소로 바꾸라는 거였습니다. 공격자가 통제하는 도메인이었고, 유효한 인증서까지 갖추고 있었습니다.

토큰 유출은 코드 실행 없이 일어났습니다. Base URL이 바뀌는 순간, 클라이언트의 OAuth 로그인 토큰이 공격자 서버로 보내지기 시작합니다. 유출된 토큰은 프로덕션 엔드포인트에 그대로 재사용되어, 피해자 계정으로 요청이 날아갔습니다. 별도 세션 경로가 아니라 같은 세션 안에서 서브에이전트가 새 연결을 열면 공격자 서버로 가는 경로도 있었는데, 이것은 약 20퍼센트의 빈도로 성립했습니다.

두 페이로드는 문체에서 닮아 있었습니다. 둘 다 길고, 지루하고, 평범한 개발 지침처럼 쓰여 있었습니다. Forever의 재현 테스트에서 이 "평범함"이 실제로 변수였습니다. 보안 주의문이 많은 폴더에 같은 파일을 넣으면 에이전트가 이상으로 받아들이기 시작했고, 평범한 폴더에서는 그대로 지침으로 읽혔습니다.

## 공개 측정이 보여준 수치

아래 수치는 모두 Forever 측의 재현 테스트 결과입니다. 저희가 재현한 값이 아니라, 공개된 원장의 값입니다.

Codex 경로의 재현에서는 90퍼센트 이상의 성공률을 보고했습니다. 실제 공격에서 회수한 파일을 별도 가상 머신에서 돌린 결과입니다. Claude Code 경로에서는 전체 테스트의 약 절반에서 지침을 따랐습니다. 절반이라는 숫자가 주는 메시지는 명확합니다. 공격이 "매번 되는" 구멍이 아니라, "되기도 하는" 표면이라는 뜻입니다. 보안에서는 이 차이가 거의 없습니다. 한 번 성공한 탈취는 반복 가능한 탈취입니다.

![Codex 90퍼센트 초과, Claude Code 약 50퍼센트 익스플로잇 재현 성공률 비교](/assets/images/markdown-new-executable-slide-05.webp)
*두 에이전트 환경에서의 재현 성공률 비교입니다. 절반의 준수율 뒤에 있는 문체 판별 변수까지 함께 읽을 수 있습니다.*

## 방 안의 메모를 안 읽게 하는 법

방어도 메모 비유 그대로입니다. 첫째, 수신실에서 일하지 마십시오. ~/Downloads를 에이전트의 작업 폴더로 쓰는 순간, 그 폴더는 누구나 메모를 남길 수 있는 공개 구역이 됩니다. 프로젝트 루트에서 시작하고, 작업 영역을 필요한 만큼 좁게 유지하는 것 자체가 방어입니다.

둘째, 낯선 메모를 읽기 전에 확인하십시오. 모르는 AGENTS.md나 CLAUDE.md가 폴더에 있는 경우, 내용을 검토하기 전까지 그 폴더에서 에이전트를 시작하지 않는 겁니다. 셋째, 설정 파일이 고쳐진 적이 있는지 읽어 보십시오.

```bash
# Codex: 등록되지 않은 mcp_servers 항목이 있는지
grep -n "mcp_servers" ~/.codex/config.toml

# Claude Code: Base URL이 제가 고르지 않은 주소로 바뀌었는지
cat .claude/settings.json | grep -n "ANTHROPIC_BASE_URL\|proxy"

# npm: function-color가 설치된 적이 있는 머신은 전면 compromise로 간주
npm ls function-color
```

넷째, 승인 프롬프트와 샌드박스 보호를 켜 둔 채로 두십시오. 두 페이로드 모두 승인을 무력화하는 방향을 시도했습니다. Codex 경로는 --dangerously-bypass-approvals-and-sandbox 플래그를 명시했고, Claude Code 경로는 보통 승인 필요한 .claude/settings.json 작성을 지시했습니다. 승인이 기본값인 환경에서 이런 지시가 눈에 띌 가능성이 가장 높습니다. 다섯째, 유출이 의심되면 자격 증명을 회전하십시오. 토큰 유출 경로는 코드 실행을 수반하지 않으므로, "코드 실행 로그가 없으니까 안전하다"는 판단이 통하지 않습니다.

![격리, 검증, 감사, 보호, 대응으로 정리한 5단계 방어 목록](/assets/images/markdown-new-executable-slide-06.webp)
*위 5단계 방어 체크리스트를 한 장으로 정리한 것입니다.*

## ThakiCloud 제품 적용 시사점

이 공격은 Paxis의 위협 모델이 처음부터 가정해 온 시나리오 그 자체입니다. Paxis는 에이전트의 모든 행동을 일급 리소스인 스킬·도구·정책으로 통제한 뒤, 정책 게이트와 감사 로그를 통과시킨 뒤 실행합니다. "방의 메모를 믿고 일하는 새 사원"을 막는 구조가, 실행 환경을 설계하는 순간부터 들어가는 이유입니다.

구체적으로 세 가지를 짚을 수 있습니다. 첫째, 지침 파일의 출처 검증. Paxis의 스킬 선택은 BM25 인덱스로 등록된 스킬만 실행 대상이 됩니다. 등록되지 않은 문서가 실행 지시로 읽히는 경로 자체가 없기 때문에, Downloads 폴더 공격의 전제인 "방의 모든 메모를 지침으로 읽는다"가 성립하지 않습니다.

둘째, 자격 증명 경로의 고정. ANTHROPIC_BASE_URL을 런타임 문서가 고칠 수 있으면, 이 공격의 Claude Code 경로가 그대로 통합니다. Paxis의 MCP 커넥터는 인증 경로와 대상이 정책으로 고정되고, 실행 중 문서가 그것을 바꾸려 하면 감사 로그에 남습니다. 셋째, 격리 실행. 샌드박스 안에서 에이전트가 자기 설정 파일에 쓰는 행위는 격리되어, 머신 전체의 계정에 영향이 가지 않습니다. Codex 경로가 머신 전체 설정을 노렸던 것과 대비되는 지점입니다.

![출처 검증, 자격 증명 고정, 격리 실행의 Paxis 3층 구조](/assets/images/markdown-new-executable-slide-07.webp)
*이 공격을 무력화하는 Paxis의 3층 구조입니다. 출처 검증과 자격 증명 고정, 격리 실행이 각자의 역할을 합니다.*

ai-platform 렌즈에서도 한 줄 있습니다. 멀티테넌트 서빙 환경에서 토큰은 테넌트 간 격리의 경계입니다. 유출된 토큰이 프로덕션 엔드포인트에 재사용된 이 사례는, 서빙 플랫폼이 인증 경로를 코드와 정책으로 고정해야 하는 이유를 다시 보여 줍니다.

## 한계 및 반론

이 공격이 "에이전트는 항상 위험하다"를 증명하지는 않습니다. 두 페이로드 모두 승인을 무력화하는 방향으로 시도했고, 승인이 기본값인 환경에서는 그런 지시 자체가 의심 대상이 됩니다. Forever의 재현에서도 절반 수준의 준수율이라는 사실은, 모델의 문체 판별 능력이 상당 부분 방어에 기여한다는 뜻이기도 합니다.

반대로 "평범한 문서가 반칙"이라는 지적도 있습니다. 지침 파일이 길고 지루할수록 공격에 유리했다는 재현 결과는, 정당한 운영 지침과 공격 페이로드를 문체로만 구분하는 것이 구조적으로 어렵다는 뜻입니다. 그래서 방어의 중심은 "어디서 읽느냐"와 "설정 파일이 바뀌었느냐"로 옮겨야 합니다. 콘텐츠 판독이 아니라, 경계의 판독입니다.

또 하나, Codex와 Claude Code 두 제품만 해당한다고 읽으면 안 됩니다. Forever의 결론도 마찬가지입니다. 로컬 지침 파일을 읽고 자기 설정을 고칠 수 있는 능력은 특정 벤더의 결함이 아니라, 에이전트 범주의 속성입니다. Cursor CLI를 포함한 여러 코딩 에이전트에 같은 전제가 적용됩니다.

## 정리

방 안의 메모를 믿는 새 사원을 고용하기 전, 고용주가 정해야 할 규칙은 세 가지입니다. 어디서 일하게 할지. 낯선 메모는 읽기 전에 확인할지. 사원증 발급 키, 즉 설정 파일이 바뀌면 알 수 있을지.

~/Downloads 폴더는 공개 구역입니다. 그 구역에서 에이전트를 시작하지 않는 것, 낯선 AGENTS.md와 CLAUDE.md를 검토하지 않고 열지 않는 것, config.toml과 settings.json의 인증 경로를 주기적으로 읽어 보는 것, 이 셋이 지금 당장 가능한 전부입니다. function-color가 들어간 머신은 전면 compromise로 취급하고, 토큰은 유출 의심 시 회전합니다.

마크다운은 여전히 종이입니다. 다만 그 종이를 읽는 에이전트가, 자기 사원증 발급 키까지 문서에 맡기는 존재가 됐을 뿐입니다.

## 출처

- [Forever Security, Hijacking AI Agents via Downloads Folder](https://forever.security/blog/hijacking-ai-agents-via-downloads-folder) (원본 공개 자료)
- [BleepingComputer, AI coding agents hijacked using AGENTS.md file in Downloads folder](https://www.bleepingcomputer.com/news/security/ai-coding-agents-hijacked-using-agentsmd-file-in-downloads-folder/)
- [The Hacker News, Malicious File in Downloads Folder Tries to Trick AI Coding Agent](https://thehackernews.com/2026/10/malicious-file-in-downloads-folder.html)
- 원 트윗: [@0xWatkin](https://x.com/0xWatkin/status/2114538646254633135)

이 글은 X에서 @0xWatkin이 공유한 공개 제보와 보안 업체 Forever의 원 자료를 바탕으로 작성했습니다.
