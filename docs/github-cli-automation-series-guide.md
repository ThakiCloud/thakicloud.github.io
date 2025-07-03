# GitHub CLI Automation Series - Complete Guide

## 개요

이 문서는 macOS용 GitHub CLI 완전 자동화 시리즈에 대한 전체 가이드입니다. 5부작으로 구성된 이 시리즈는 개발자의 터미널 기반 워크플로우를 완전히 자동화하는 프로덕션 준비가 완료된 시스템을 제공합니다.

## 시리즈 구성

### Part 1: Installation and Environment Setup
**파일**: `2025-07-02-macos-github-cli-complete-guide.md`

**주요 내용**:
- 다중 계정 GitHub CLI 관리 (토큰 전환 시스템)
- 고급 zshrc 구성 (600+ 라인) 
- 컨텍스트 기반 워크스페이스 분리 (work/personal)
- 스마트 리포지토리 클로닝 및 프로젝트 초기화

**핵심 기능**:
- 자동 Git 설정 전환
- 작업/개인 프로젝트 디렉터리 분리
- 인텔리전트 프로젝트 템플릿 감지

### Part 2: Issue Management Complete Automation
**파일**: `2025-07-02-macos-github-cli-issue-automation-guide.md`

**주요 내용**:
- AI 기반 이슈 분류 시스템 (키워드 감지)
- 프로젝트 타입별 동적 이슈 템플릿 생성
- 스프린트 계획 자동화 (마일스톤 관리)
- 이슈 워크플로우 자동화 (todo → in-progress → review → testing → done)
- 분석 대시보드 및 상태 확인

**핵심 기능**:
- 원클릭 이슈 생성 및 할당
- 자동 라벨링 및 프로젝트 보드 연동
- 스프린트 번다운 차트 및 속도 추적

### Part 3: Project Management + Work/Personal Separation
**파일**: `2025-07-02-github-cli-project-management-automation.md`

**주요 내용**:
- 컨텍스트 인식 프로젝트 생성 (work/personal 템플릿)
- GitHub Projects v2 자동화 (커스텀 필드)
- 팀 협업 워크플로우 (스탠드업 보고서, 리뷰어 할당)
- 자동 프로젝트 메트릭 및 리포팅

**핵심 기능**:
- 기술 스택 감지 기반 프로젝트 템플릿
- 팀 멤버 자동 할당 시스템
- 프로젝트 상태 실시간 모니터링

### Part 4: Wiki Management Complete Automation
**파일**: `2025-07-02-github-cli-wiki-automation-guide.md`

**주요 내용**:
- 모듈러 스크립트 시스템 (`~/scripts/github-cli/` 구조)
- 코드 및 README 파일로부터 자동 위키 생성
- API 문서 자동 생성 (OpenAPI 스펙 또는 코드 파싱)
- 다국어 위키 지원 (한국어, 영어, 일본어, 중국어)
- 위키 품질 검증 및 링크 체크

**핵심 기능**:
- 코드 변경 시 위키 자동 동기화
- 다국어 템플릿 시스템
- API 문서 자동 업데이트

### Part 5: Advanced Workflows and Production Implementation
**파일**: `2025-07-02-github-cli-advanced-workflows.md`

**주요 내용**:
- 마스터 제어 시스템 (상태 모니터링)
- CI/CD 파이프라인 통합 (GitHub Actions)
- 팀 온보딩 자동화 (체크리스트 생성)
- 통합 명령어 시스템 (`gh` 명령어 오버라이드)
- 성능 최적화 및 백업 시스템

**핵심 기능**:
- 시스템 상태 진단 (`gh_system_status`, `gh_system_doctor`)
- 완전 자동화된 온보딩 프로세스
- 통합 대시보드 시스템

## 기술적 구현 세부사항

### 스크립트 아키텍처
```
~/scripts/github-cli/
├── core/
│   ├── auth.sh           # 인증 및 계정 전환
│   ├── context.sh        # 컨텍스트 관리
│   └── utils.sh          # 유틸리티 함수
├── issue/
│   ├── create.sh         # 이슈 생성
│   ├── manage.sh         # 이슈 관리
│   └── workflow.sh       # 워크플로우 자동화
├── project/
│   ├── create.sh         # 프로젝트 생성
│   ├── manage.sh         # 프로젝트 관리
│   └── templates/        # 프로젝트 템플릿
├── wiki/
│   ├── generate.sh       # 위키 생성
│   ├── sync.sh           # 동기화
│   └── templates/        # 위키 템플릿
└── system/
    ├── health.sh         # 시스템 상태 체크
    ├── backup.sh         # 백업 시스템
    └── dashboard.sh      # 대시보드
```

### 핵심 명령어 시스템

#### 일일 워크플로우
```bash
# 하루 시작
gh_start_day                    # 대시보드 표시 + 활성 이슈 확인

# 이슈 작업
issue_start "feature-login"     # 이슈 시작 (브랜치 생성 + 상태 변경)
issue_finish "feature-login"    # 이슈 완료 (PR 생성 + 상태 변경)

# 위키 업데이트
wiki_update                     # 코드 변경사항 기반 위키 자동 업데이트

# 시스템 상태 확인
gh_system_status               # 전체 시스템 상태 확인
gh_system_doctor               # 문제 진단 및 해결 제안
```

#### 프로젝트 관리
```bash
# 프로젝트 생성
project_create "my-api" --type=work --tech=nodejs
project_create "blog" --type=personal --tech=gatsby

# 팀 관리
team_onboard "new-developer"    # 신규 개발자 온보딩
team_standup                    # 스탠드업 보고서 생성
```

#### 컨텍스트 전환
```bash
# 계정 전환
gh_switch_work                  # 회사 계정으로 전환
gh_switch_personal              # 개인 계정으로 전환

# 워크스페이스 이동
work                           # 회사 프로젝트 디렉터리
personal                       # 개인 프로젝트 디렉터리
```

### 자동화 시스템 특징

#### 1. 인텔리전트 분류
- **이슈 분류**: 키워드 기반 자동 라벨링 및 담당자 할당
- **프로젝트 감지**: 기술 스택 자동 감지로 적절한 템플릿 적용
- **우선순위 결정**: 이슈 중요도 및 긴급도 자동 평가

#### 2. 컨텍스트 인식
- **작업 환경 분리**: 회사/개인 프로젝트 완전 분리
- **자동 Git 설정**: 컨텍스트별 사용자 정보 및 SSH 키 자동 전환
- **템플릿 선택**: 프로젝트 타입에 따른 적절한 템플릿 자동 선택

#### 3. 완전 자동화
- **이슈 → PR 워크플로우**: 이슈 생성부터 PR 완료까지 원클릭
- **위키 동기화**: 코드 변경 시 관련 문서 자동 업데이트
- **팀 온보딩**: 신규 팀원 계정 생성부터 프로젝트 액세스까지 자동화

#### 4. 모니터링 및 건강성 체크
- **실시간 대시보드**: 활성 프로젝트, 진행 중인 이슈, 팀 상태 한눈에 확인
- **시스템 진단**: 설정 오류, 토큰 만료, 연결 문제 등 자동 감지
- **성능 최적화**: 스크립트 실행 시간 및 API 호출 최적화

## 설치 및 설정

### 1. 시스템 요구사항
- macOS 10.15 이상
- Homebrew 설치
- Git 설치
- zsh 쉘 (기본값)

### 2. 설치 순서
1. **Part 1**: 기본 환경 설정 및 GitHub CLI 설치
2. **Part 2**: 이슈 관리 스크립트 설치
3. **Part 3**: 프로젝트 관리 시스템 설치
4. **Part 4**: 위키 자동화 시스템 설치
5. **Part 5**: 고급 워크플로우 및 통합 시스템 설치

### 3. 설정 검증
```bash
# 전체 시스템 상태 확인
gh_system_doctor

# 개별 컴포넌트 테스트
test_github_auth            # 인증 테스트
test_issue_workflow         # 이슈 워크플로우 테스트
test_wiki_generation        # 위키 생성 테스트
test_project_creation       # 프로젝트 생성 테스트
```

## 사용 시나리오

### 시나리오 1: 신규 기능 개발
```bash
# 1. 이슈 생성 및 시작
issue_create "로그인 기능 구현" --type=feature --priority=high
issue_start "login-feature"

# 2. 개발 진행
# ... 코딩 작업 ...

# 3. 이슈 완료
issue_finish "login-feature"  # PR 생성 + 리뷰 요청 + 상태 업데이트
```

### 시나리오 2: 새 프로젝트 시작
```bash
# 1. 프로젝트 생성
project_create "ecommerce-api" --type=work --tech=nodejs

# 2. 팀 설정
team_add_members "dev-team" "ecommerce-api"

# 3. 초기 이슈 생성
issue_bulk_create "project-setup.yaml"
```

### 시나리오 3: 팀 온보딩
```bash
# 1. 신규 개발자 온보딩
team_onboard "jane.doe@company.com"

# 2. 프로젝트 액세스 권한 부여
project_add_member "ecommerce-api" "jane.doe"

# 3. 온보딩 체크리스트 생성
onboarding_checklist "jane.doe"
```

## 고급 기능

### 1. 커스텀 워크플로우
- 프로젝트별 맞춤형 워크플로우 정의
- 자동 코드 리뷰 규칙 설정
- 배포 파이프라인 통합

### 2. 분석 및 리포팅
- 개발 생산성 메트릭
- 팀 협업 효율성 분석
- 이슈 해결 시간 추적

### 3. 통합 시스템
- Slack/Discord 알림 연동
- JIRA/Asana 동기화
- IDE 플러그인 지원

## 문제 해결

### 일반적인 문제
1. **인증 문제**: `gh_auth_refresh` 명령어로 토큰 갱신
2. **스크립트 권한 문제**: `chmod +x ~/scripts/github-cli/**/*.sh`
3. **API 제한 문제**: `gh_api_status`로 API 사용량 확인

### 디버깅 도구
```bash
# 상세 로그 활성화
export GH_DEBUG=1

# 특정 기능 디버깅
debug_issue_workflow "issue-123"
debug_wiki_generation "my-project"
```

## 결론

이 5부작 시리즈는 GitHub CLI를 활용한 완전 자동화 시스템을 구축하여 개발자의 생산성을 극대화합니다. 

**주요 달성 목표**:
- 🚀 **생산성 향상**: 반복 작업 자동화로 개발에 집중
- 🔄 **워크플로우 표준화**: 팀 전체의 일관된 작업 프로세스
- 📊 **투명성 증대**: 실시간 프로젝트 상태 및 진행도 추적
- 🛡️ **품질 보장**: 자동 검증 및 문서화로 품질 향상
- 👥 **협업 강화**: 팀 온보딩 및 커뮤니케이션 자동화

이 시스템을 통해 개발팀은 이슈 생성부터 프로젝트 완료까지의 전체 라이프사이클을 효율적으로 관리할 수 있습니다. 