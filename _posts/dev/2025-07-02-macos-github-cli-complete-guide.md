---
title: "macOS GitHub CLI 완전 가이드: 이슈부터 프로젝트, 위키까지"
excerpt: "macOS에서 GitHub CLI로 이슈 생성, 프로젝트 관리, 위키 작성을 터미널에서 완벽하게 처리하는 단계별 가이드"
seo_title: "macOS GitHub CLI 완전 가이드 - 이슈, 프로젝트, 위키 관리 - Thaki Cloud"
seo_description: "macOS 환경에서 GitHub CLI(gh)를 사용하여 이슈 생성, 프로젝트 관리, 위키 작성까지 터미널에서 모든 GitHub 작업을 효율적으로 처리하는 방법을 단계별로 설명합니다."
date: 2025-07-02
last_modified_at: 2025-07-02
categories:
  - dev
  - tutorials
tags:
  - github-cli
  - macos
  - github
  - git
  - terminal
  - homebrew
  - project-management
  - issue-tracking
  - wiki
  - markdown
  - workflow
  - productivity
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
header:
  teaser: "/assets/images/thumbnails/post-thumbnail.jpg"
  overlay_image: "/assets/images/headers/post-header.jpg"
  overlay_filter: 0.5
canonical_url: "https://thakicloud.github.io/dev/macos-github-cli-complete-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 15분

## 서론

개발자라면 GitHub을 웹 브라우저에서 사용하는 것이 일반적이지만, **GitHub CLI (gh)**를 활용하면 터미널에서 모든 GitHub 작업을 효율적으로 처리할 수 있습니다. 특히 macOS 환경에서는 Homebrew와 함께 사용하면 매우 강력한 개발 워크플로우를 구축할 수 있습니다.

이 가이드에서는 **GitHub CLI를 사용하여 이슈 생성, 프로젝트 관리, 위키 작성**까지 터미널에서 완벽하게 처리하는 방법을 단계별로 설명합니다.

## GitHub CLI 설치 및 초기 설정

### 1. Homebrew로 GitHub CLI 설치

```bash
# Homebrew가 없다면 먼저 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# GitHub CLI 설치
brew install gh

# 설치 확인
gh --version
```

### 2. GitHub CLI 로그인

```bash
# 인터랙티브 로그인 (웹 브라우저 사용)
gh auth login

# 선택 옵션:
# ? What account do you want to log into? GitHub.com
# ? What is your preferred protocol for Git operations? HTTPS
# ? Authenticate Git with your GitHub credentials? Yes
# ? How would you like to authenticate GitHub CLI? Login with a web browser
```

**로그인 과정**:
1. `gh auth login` 실행
2. GitHub.com 선택
3. HTTPS 프로토콜 선택 (또는 SSH)
4. Git 자격증명 연동 선택
5. 웹 브라우저로 인증 선택
6. 터미널에 표시된 코드를 브라우저에 입력
7. GitHub에서 권한 승인

### 3. 로그인 상태 확인

```bash
# 로그인 상태 확인
gh auth status

# 출력 예시:
# github.com
#   ✓ Logged in to github.com as username (/Users/username/.config/gh/hosts.yml)
#   ✓ Git operations for github.com configured to use https protocol.
#   ✓ Token: *******************

# 현재 사용자 정보 확인
gh api user
```

### 4. GitHub CLI 설정 커스터마이징

```bash
# 기본 에디터 설정
gh config set editor "code"  # VS Code
# 또는
gh config set editor "vim"   # Vim

# 기본 브라우저 설정
gh config set browser "open" # macOS 기본 브라우저

# 설정 확인
gh config list
```

## GitHub 이슈 관리

### 1. 이슈 조회 및 검색

```bash
# 현재 리포지토리의 모든 이슈 조회
gh issue list

# 내가 할당된 이슈만 조회
gh issue list --assignee @me

# 특정 상태의 이슈 조회
gh issue list --state open
gh issue list --state closed

# 라벨로 필터링
gh issue list --label "bug"
gh issue list --label "enhancement,priority:high"

# 검색 쿼리 사용
gh issue list --search "is:open label:bug author:username"
```

### 2. 이슈 생성

#### 기본 이슈 생성
```bash
# 인터랙티브 이슈 생성
gh issue create

# 직접 이슈 생성
gh issue create \
  --title "🚨 Sass Deprecation Warnings 해결 필요" \
  --body "Jekyll 빌드 시 multiple Sass deprecation warnings가 발생하고 있습니다."

# 템플릿에서 이슈 생성
gh issue create --template bug_report.md
```

#### 고급 이슈 생성
```bash
# 라벨, 담당자, 마일스톤과 함께 이슈 생성
gh issue create \
  --title "API 응답 시간 최적화" \
  --body "$(cat issue-description.md)" \
  --label "performance,api" \
  --assignee "devteam" \
  --milestone "v2.0" \
  --project "Backend Optimization"

# 파일에서 본문 읽어오기
echo "## 문제 상황

Jekyll 빌드 시 다음과 같은 Sass deprecation 경고가 발생합니다:

- Color functions deprecation
- Slash division deprecation

## 해결 방안

1. Color functions 마이그레이션
2. Division operations 마이그레이션" > issue-body.md

gh issue create \
  --title "Sass Deprecation Warnings 수정" \
  --body-file issue-body.md \
  --label "bug,sass"
```

### 3. 이슈 관리 및 업데이트

```bash
# 이슈 상세 조회
gh issue view 123

# 이슈에 댓글 추가
gh issue comment 123 --body "작업을 시작했습니다."

# 이슈 편집
gh issue edit 123 \
  --title "새로운 제목" \
  --add-label "in-progress" \
  --remove-label "todo"

# 이슈 상태 변경
gh issue close 123
gh issue reopen 123

# 이슈에 반응 추가
gh issue view 123 --comments | gh api graphql -f query='
  mutation($subjectId: ID!) {
    addReaction(input: {subjectId: $subjectId, content: THUMBS_UP}) {
      reaction { content }
    }
  }' -f subjectId='{댓글ID}'
```

### 4. 이슈 템플릿 활용

```bash
# .github/ISSUE_TEMPLATE/ 디렉토리 생성
mkdir -p .github/ISSUE_TEMPLATE

# 버그 리포트 템플릿 생성
cat > .github/ISSUE_TEMPLATE/bug_report.md << 'EOF'
---
name: 🐛 Bug Report
about: 버그를 신고해주세요
title: '[BUG] '
labels: 'bug'
assignees: ''
---

## 🐛 버그 설명
버그에 대한 명확하고 간결한 설명을 작성해주세요.

## 🔄 재현 단계
1. '...'로 이동
2. '....'를 클릭
3. '....'까지 스크롤
4. 오류 확인

## ✅ 예상 결과
어떤 결과를 예상했는지 설명해주세요.

## ❌ 실제 결과
실제로 어떤 일이 일어났는지 설명해주세요.

## 📱 환경
- OS: [예: macOS 13.0]
- 브라우저: [예: Chrome 91.0]
- 버전: [예: v1.0.0]

## 📎 추가 정보
스크린샷, 로그, 추가 컨텍스트를 첨부해주세요.
EOF

# 기능 요청 템플릿 생성
cat > .github/ISSUE_TEMPLATE/feature_request.md << 'EOF'
---
name: 🚀 Feature Request
about: 새로운 기능을 제안해주세요
title: '[FEATURE] '
labels: 'enhancement'
assignees: ''
---

## 🚀 기능 설명
어떤 기능을 원하는지 명확하고 간결하게 설명해주세요.

## 💡 동기
이 기능이 왜 필요한지, 어떤 문제를 해결하는지 설명해주세요.

## 📋 상세 요구사항
- [ ] 요구사항 1
- [ ] 요구사항 2
- [ ] 요구사항 3

## 🎨 UI/UX 고려사항
사용자 인터페이스나 사용자 경험 관련 고려사항이 있다면 설명해주세요.

## 🔧 기술적 고려사항
구현 시 고려해야 할 기술적 사항들을 나열해주세요.
EOF
```

## GitHub 프로젝트 관리

### 1. 프로젝트 조회

```bash
# 조직의 프로젝트 목록
gh project list --owner "organization-name"

# 개인 프로젝트 목록  
gh project list --owner @me

# 특정 프로젝트 상세 조회
gh project view 123
```

### 2. 프로젝트 생성

```bash
# 기본 프로젝트 생성
gh project create \
  --title "Q4 개발 로드맵" \
  --body "2024년 4분기 주요 개발 계획"

# 템플릿으로 프로젝트 생성
gh project create \
  --title "Backend API 개선" \
  --body "API 성능 최적화 및 새로운 엔드포인트 개발" \
  --template "Team planning"
```

### 3. 프로젝트 필드 관리

```bash
# 프로젝트에 커스텀 필드 추가
gh project field-create 123 \
  --name "Priority" \
  --type "single_select" \
  --options "Low,Medium,High,Critical"

gh project field-create 123 \
  --name "Estimated Hours" \
  --type "number"

gh project field-create 123 \
  --name "Due Date" \
  --type "date"

# 필드 목록 조회
gh project field-list 123
```

### 4. 프로젝트 아이템 관리

```bash
# 이슈를 프로젝트에 추가
gh project item-add 123 --url "https://github.com/owner/repo/issues/456"

# Pull Request를 프로젝트에 추가
gh project item-add 123 --url "https://github.com/owner/repo/pull/789"

# 아이템 필드 업데이트
gh project item-edit \
  --project-id 123 \
  --id ITEM_ID \
  --field-id FIELD_ID \
  --text "High"

# 아이템 상태 변경
gh project item-edit \
  --project-id 123 \
  --id ITEM_ID \
  --field-id STATUS_FIELD_ID \
  --single-select-option-id "In Progress"
```

### 5. 프로젝트 뷰 관리

```bash
# 새 뷰 생성
gh project view-create 123 \
  --name "Sprint 백로그" \
  --layout "table"

# 필터가 있는 뷰 생성
gh project view-create 123 \
  --name "High Priority Items" \
  --layout "board" \
  --filter "Priority:High"

# 뷰 목록 조회
gh project view-list 123
```

## GitHub 위키 관리

### 1. 위키 초기 설정

```bash
# 위키 활성화 (리포지토리 설정에서)
gh api repos/:owner/:repo -X PATCH -f has_wiki=true

# 위키 클론
git clone https://github.com/owner/repo.wiki.git
cd repo.wiki

# 위키 리포지토리 확인
ls -la
```

### 2. 위키 페이지 생성

#### 홈 페이지 생성
```bash
# 위키 홈 페이지 생성
cat > Home.md << 'EOF'
# 프로젝트 위키

이 위키는 프로젝트의 문서화를 위한 공간입니다.

## 📚 문서 구조

- [설치 가이드](Installation-Guide)
- [API 문서](API-Documentation)
- [FAQ](FAQ)
- [트러블슈팅](Troubleshooting)

## 🚀 빠른 시작

1. [설치 가이드](Installation-Guide)를 따라 환경을 설정하세요
2. [API 문서](API-Documentation)에서 사용법을 확인하세요
3. 문제가 있다면 [FAQ](FAQ)를 확인하세요

## 📞 지원

문제가 있다면 [이슈](../../issues)를 생성해주세요.
EOF
```

#### API 문서 페이지 생성
```bash
cat > API-Documentation.md << 'EOF'
# API 문서

## 인증

모든 API 요청에는 인증이 필요합니다.

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://api.example.com/v1/users
```

## 엔드포인트

### 사용자 관리

#### GET /api/v1/users
사용자 목록을 조회합니다.

**매개변수:**
- `page` (선택사항): 페이지 번호 (기본값: 1)
- `limit` (선택사항): 페이지당 항목 수 (기본값: 20)

**응답:**
```json
{
  "users": [
    {
      "id": 1,
      "username": "john_doe",
      "email": "john@example.com"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}
```

#### POST /api/v1/users
새 사용자를 생성합니다.

**요청 본문:**
```json
{
  "username": "string",
  "email": "string",
  "password": "string"
}
```

**응답:**
```json
{
  "id": 123,
  "username": "new_user",
  "email": "new@example.com",
  "created_at": "2024-01-01T00:00:00Z"
}
```
EOF
```

#### 설치 가이드 생성
```bash
cat > Installation-Guide.md << 'EOF'
# 설치 가이드

## 시스템 요구사항

- Node.js 18+ 
- npm 8+
- Git

## 설치 과정

### 1. 리포지토리 클론

```bash
git clone https://github.com/owner/repo.git
cd repo
```

### 2. 의존성 설치

```bash
npm install
```

### 3. 환경 변수 설정

```bash
cp .env.example .env
```

필요한 환경 변수를 `.env` 파일에 설정하세요:

```env
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
JWT_SECRET=your-secret-key
PORT=3000
```

### 4. 데이터베이스 설정

```bash
npm run db:migrate
npm run db:seed
```

### 5. 개발 서버 실행

```bash
npm run dev
```

서버가 http://localhost:3000에서 실행됩니다.

## 배포

### Docker를 사용한 배포

```bash
# 이미지 빌드
docker build -t myapp .

# 컨테이너 실행
docker run -p 3000:3000 myapp
```

### PM2를 사용한 배포

```bash
# PM2 전역 설치
npm install -g pm2

# 애플리케이션 시작
pm2 start ecosystem.config.js

# 상태 확인
pm2 status
```
EOF
```

### 3. 위키 커밋 및 푸시

```bash
# 위키 변경사항 추가
git add .

# 커밋
git commit -m "docs: 초기 위키 페이지 생성

- 홈 페이지 추가
- API 문서 추가  
- 설치 가이드 추가"

# 푸시
git push origin master

# 위키 페이지 확인
open "https://github.com/owner/repo/wiki"
```

### 4. 위키 고급 기능

#### 이미지 및 파일 첨부
```bash
# 이미지 디렉토리 생성
mkdir images

# 이미지 추가 (GitHub에서는 위키에 직접 파일 업로드 불가)
# 대신 이슈나 PR에 이미지를 업로드한 후 URL 사용

# 마크다운에서 이미지 참조
echo '![Architecture Diagram](https://user-images.githubusercontent.com/user/image.png)' >> Architecture.md
```

#### 페이지 간 링크
```bash
cat > FAQ.md << 'EOF'
# 자주 묻는 질문

## 일반적인 질문

### Q: 설치 중 오류가 발생합니다
A: [설치 가이드](Installation-Guide)를 다시 확인하고, [트러블슈팅](Troubleshooting) 페이지를 참조하세요.

### Q: API 사용법을 알고 싶습니다
A: [API 문서](API-Documentation)에서 상세한 정보를 확인할 수 있습니다.

### Q: 기여하고 싶습니다
A: [컨트리뷰션 가이드](Contributing)를 확인해주세요.

## 기술적 질문

### Q: 데이터베이스 연결 오류
A: 환경 변수가 올바르게 설정되었는지 확인하세요:

```env
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
```

### Q: 포트 충돌 오류
A: `.env` 파일에서 다른 포트를 사용하세요:

```env
PORT=3001
```
EOF
```

## 실무 워크플로우 최적화

### 1. 이슈 기반 개발 워크플로우

```bash
#!/bin/bash
# 이슈 기반 개발을 위한 스크립트 (~/bin/issue-branch.sh)

# 사용법: issue-branch.sh 123 "feature description"
ISSUE_NUM=$1
DESCRIPTION=$2

if [ -z "$ISSUE_NUM" ] || [ -z "$DESCRIPTION" ]; then
    echo "사용법: issue-branch.sh <이슈번호> <설명>"
    exit 1
fi

# 이슈 정보 가져오기
ISSUE_TITLE=$(gh issue view $ISSUE_NUM --json title -q '.title')

# 브랜치명 생성 (이슈번호-간단한설명)
BRANCH_NAME="issue-${ISSUE_NUM}-$(echo $DESCRIPTION | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"

# 브랜치 생성 및 체크아웃
git checkout -b $BRANCH_NAME

# 이슈에 작업 시작 댓글 추가
gh issue comment $ISSUE_NUM --body "🚀 작업을 시작했습니다. 브랜치: \`$BRANCH_NAME\`"

echo "브랜치 '$BRANCH_NAME' 생성 완료"
echo "이슈: $ISSUE_TITLE"
```

### 2. 자동화된 프로젝트 업데이트

```bash
#!/bin/bash
# 프로젝트 아이템 자동 업데이트 스크립트

PROJECT_ID="123"
ISSUE_URL="https://github.com/owner/repo/issues/$1"

# 이슈를 프로젝트에 추가
ITEM_ID=$(gh project item-add $PROJECT_ID --url $ISSUE_URL --format json | jq -r '.id')

# 상태를 "In Progress"로 변경
gh project item-edit \
    --project-id $PROJECT_ID \
    --id $ITEM_ID \
    --field-id "Status" \
    --single-select-option-id "In Progress"

echo "이슈 #$1이 프로젝트에 추가되고 'In Progress' 상태로 설정되었습니다."
```

### 3. 일일 대시보드 스크립트

```bash
#!/bin/bash
# 일일 GitHub 대시보드 (~/bin/github-dashboard.sh)

echo "🚀 GitHub 일일 대시보드"
echo "========================"
echo

echo "📋 내 할당 이슈:"
gh issue list --assignee @me --state open --limit 5

echo
echo "🔄 리뷰 대기 중인 PR:"
gh pr list --search "review-requested:@me" --limit 5

echo
echo "✅ 최근 닫힌 이슈:"
gh issue list --assignee @me --state closed --limit 3

echo
echo "📊 프로젝트 현황:"
gh project list --owner @me --limit 3

echo
echo "📈 이번 주 활동:"
gh api graphql -f query='
query($login: String!) {
  user(login: $login) {
    contributionsCollection {
      contributionCalendar {
        totalContributions
        weeks {
          contributionDays {
            contributionCount
            date
          }
        }
      }
    }
  }
}' -f login=$(gh api user -q .login) | jq -r '.data.user.contributionsCollection.contributionCalendar.totalContributions'
```

### 4. 위키 자동 업데이트

```bash
#!/bin/bash
# API 문서 자동 생성 및 위키 업데이트

# OpenAPI 스펙에서 마크다운 생성 (swagger-codegen 사용)
swagger-codegen generate \
    -i api-spec.yaml \
    -l markdown \
    -o /tmp/api-docs

# 위키 리포지토리로 복사
cp /tmp/api-docs/README.md repo.wiki/API-Documentation.md

# 위키 업데이트
cd repo.wiki
git add API-Documentation.md
git commit -m "docs: API 문서 자동 업데이트 $(date '+%Y-%m-%d')"
git push origin master

echo "API 문서가 위키에 업데이트되었습니다."
```

## 고급 GitHub CLI 활용

### 1. GitHub CLI 확장 설치

```bash
# 인기 확장 설치
gh extension install github/gh-copilot  # GitHub Copilot
gh extension install dlvhdr/gh-dash     # 대시보드
gh extension install vilmibm/gh-screensaver  # 재미있는 확장

# 확장 목록 확인
gh extension list

# 확장 사용
gh dash  # 대시보드 실행
```

### 2. 커스텀 GitHub CLI 명령어

```bash
# ~/.config/gh/config.yml에 alias 추가
gh alias set prc 'pr create --draft --title "$1" --body "## 변경사항\n\n- \n\n## 체크리스트\n\n- [ ] 테스트 통과\n- [ ] 문서 업데이트"'

# 사용
gh prc "새로운 기능 구현"
```

### 3. GitHub Actions와 연동

```bash
# 워크플로우 실행
gh workflow run "CI/CD"

# 워크플로우 상태 확인
gh run list --workflow="CI/CD"

# 실패한 워크플로우 로그 확인
gh run view 123456 --log-failed
```

## 보안 및 베스트 프랙티스

### 1. 토큰 관리

```bash
# 토큰 권한 확인
gh auth status

# 토큰 새로고침
gh auth refresh

# 다른 계정으로 로그인
gh auth login --hostname github.com
```

### 2. 환경별 설정

```bash
# 작업용 프로필
gh auth login --hostname github.com --with-token < work-token.txt

# 개인용 프로필  
gh auth login --hostname github.com --with-token < personal-token.txt

# 현재 설정 확인
gh auth status --hostname github.com
```

### 3. 자동화 스크립트 보안

```bash
# 토큰을 환경변수로 관리
export GITHUB_TOKEN="your-token"

# 스크립트에서 토큰 사용
gh api user --header "Authorization: token $GITHUB_TOKEN"
```

## 결론

GitHub CLI는 개발자의 생산성을 크게 향상시킬 수 있는 강력한 도구입니다. **터미널에서 이슈 관리부터 프로젝트 관리, 위키 작성까지** 모든 GitHub 작업을 효율적으로 처리할 수 있습니다.

### 핵심 장점

- **효율성**: 웹 브라우저 전환 없이 모든 작업 처리
- **자동화**: 스크립트를 통한 반복 작업 자동화
- **일관성**: 명령어 기반의 일관된 워크플로우
- **확장성**: 커스텀 명령어와 확장 프로그램 지원

### 추천 워크플로우

1. **이슈 중심 개발**: 모든 작업을 이슈로 시작
2. **프로젝트 보드 활용**: 진행 상황 시각화
3. **위키 문서화**: 지식 공유 및 온보딩
4. **자동화 스크립트**: 반복 작업 최소화

지금 바로 `gh auth login`으로 시작해서 개발 워크플로우를 혁신해보세요!

---

**참고 링크**:
- [GitHub CLI 공식 문서](https://cli.github.com/manual/)
- [GitHub CLI 확장 프로그램](https://github.com/topics/gh-extension)
- [GitHub REST API](https://docs.github.com/en/rest)
- [GitHub GraphQL API](https://docs.github.com/en/graphql) 