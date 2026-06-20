---
title: "Plane GitHub 연동 완전 정복 - API 자동화와 개발 워크플로우 최적화"
excerpt: "Plane과 GitHub을 완벽하게 연동하고 터미널 alias, API 스크립트로 개발 생산성을 극대화하는 실전 가이드. 실무에서 바로 사용할 수 있는 자동화 예제와 창의적인 활용법까지 완전 정복합니다."
seo_title: "Plane GitHub 연동 완전 정복 - API 자동화 개발 워크플로우 - Thaki Cloud"
seo_description: "Plane GitHub 연동 설정부터 터미널 alias API 자동화까지. 개발 워크플로우 최적화를 위한 실전 스크립트와 창의적 활용법 완전 가이드"
date: 2025-07-01
last_modified_at: 2025-07-01
categories:
  - tutorials
tags:
  - plane
  - github
  - api-automation
  - workflow
  - cli-tools
  - terminal-alias
  - webhook
  - oauth
  - project-management
  - devops
  - productivity
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/plane-github-integration-advanced-guide/"
reading_time: true
published: false
---

⏱️ **예상 읽기 시간**: 20분

## 서론

[이전 글](#)에서 Plane의 기본 설치와 설정을 다뤘다면, 이번에는 **실무 활용의 핵심**인 GitHub 연동과 API 자동화에 집중하겠습니다. 

이 가이드에서는 단순한 연동을 넘어서 **개발 생산성을 극대화**하는 창의적인 방법들을 다룹니다:

- 🔗 **완벽한 GitHub 연동**: OAuth, Webhooks, 자동 동기화
- ⚡ **터미널 슈퍼 파워**: 한 줄 명령어로 이슈 생성부터 배포까지
- 🤖 **스마트 자동화**: 커밋 메시지로 이슈 상태 자동 업데이트
- 🎯 **실무 워크플로우**: 실제 프로젝트에서 바로 사용 가능한 예제들

## GitHub 연동 설정

### 1. GitHub OAuth 애플리케이션 생성

```bash
# GitHub Settings > Developer settings > OAuth Apps
# 또는 다음 URL로 직접 접근
https://github.com/settings/applications/new
```

**필수 설정값:**
```
Application name: Plane Project Management
Homepage URL: https://your-plane-domain.com
Authorization callback URL: https://your-plane-domain.com/auth/github/callback/
```

### 2. Plane 환경 변수 설정

```bash
# .env 파일 업데이트
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret
IS_GITHUB_ENABLED=1

# API 서버 재시작
docker compose restart api
```

### 3. GitHub Personal Access Token 생성

```bash
# GitHub Settings > Developer settings > Personal access tokens > Fine-grained tokens
# 필요한 권한:
# - Repository: Issues (Read/Write)
# - Repository: Pull Requests (Read/Write)
# - Repository: Contents (Read)
# - Repository: Metadata (Read)
```

## API 기본 설정

### 1. Plane API 토큰 생성

```bash
# Plane 웹 인터페이스에서
# Settings > API Tokens > Generate New Token

# 환경 변수로 설정
export PLANE_API_TOKEN="your_plane_api_token"
export PLANE_API_BASE="https://your-plane-domain.com/api/v1"
export PLANE_WORKSPACE_ID="your_workspace_id"
export PLANE_PROJECT_ID="your_project_id"
```

### 2. 기본 API 테스트

```bash
# 워크스페이스 목록 조회
curl -H "Authorization: Bearer $PLANE_API_TOKEN" \
     "$PLANE_API_BASE/workspaces/"

# 프로젝트 목록 조회
curl -H "Authorization: Bearer $PLANE_API_TOKEN" \
     "$PLANE_API_BASE/workspaces/$PLANE_WORKSPACE_ID/projects/"
```

## 터미널 슈퍼 파워: Alias와 함수

### 1. 기본 Plane CLI 함수들

```bash
# ~/.zshrc 또는 ~/.bashrc에 추가

# Plane API 기본 함수
plane_api() {
    local method=${1:-GET}
    local endpoint=$2
    local data=$3
    
    if [ -n "$data" ]; then
        curl -s -X $method \
             -H "Authorization: Bearer $PLANE_API_TOKEN" \
             -H "Content-Type: application/json" \
             -d "$data" \
             "$PLANE_API_BASE$endpoint"
    else
        curl -s -X $method \
             -H "Authorization: Bearer $PLANE_API_TOKEN" \
             "$PLANE_API_BASE$endpoint"
    fi
}

# 이슈 빠른 생성
plane_issue() {
    local title="$1"
    local description="$2"
    local priority="${3:-medium}"
    
    local data=$(cat <<EOF
{
    "name": "$title",
    "description": "$description", 
    "priority": "$priority",
    "state": "$(plane_get_state_id 'Todo')"
}
EOF
)
    
    plane_api POST "/workspaces/$PLANE_WORKSPACE_ID/projects/$PLANE_PROJECT_ID/issues/" "$data" | jq -r '.name + " 이슈가 생성되었습니다. ID: " + .id'
}

# 상태 ID 조회 함수
plane_get_state_id() {
    local state_name="$1"
    plane_api GET "/workspaces/$PLANE_WORKSPACE_ID/projects/$PLANE_PROJECT_ID/states/" | \
    jq -r ".[] | select(.name == \"$state_name\") | .id"
}

# 이슈 상태 변경
plane_move() {
    local issue_id="$1"
    local state_name="$2"
    local state_id=$(plane_get_state_id "$state_name")
    
    local data="{\"state\": \"$state_id\"}"
    plane_api PATCH "/workspaces/$PLANE_WORKSPACE_ID/projects/$PLANE_PROJECT_ID/issues/$issue_id/" "$data"
}
```

### 2. 실무 활용 Alias 모음

```bash
# 빠른 이슈 관리
alias pi='plane_issue'                    # 이슈 생성
alias pls='plane_list_issues'            # 이슈 목록
alias pshow='plane_show_issue'           # 이슈 상세보기
alias pmv='plane_move'                   # 이슈 상태 변경

# 사이클(스프린트) 관리  
alias pcs='plane_create_cycle'           # 사이클 생성
alias pcl='plane_list_cycles'            # 사이클 목록
alias pca='plane_add_to_cycle'           # 이슈를 사이클에 추가

# GitHub 연동
alias gh2plane='github_to_plane_sync'    # GitHub 이슈 동기화
alias plane2gh='plane_to_github_sync'    # Plane 이슈를 GitHub로

# 대시보드 조회
alias pdash='plane_dashboard'            # 간단 대시보드
alias pstats='plane_statistics'          # 프로젝트 통계
```

### 3. 고급 함수들

```bash
# GitHub 이슈를 Plane으로 가져오기
github_to_plane_sync() {
    local github_repo="$1"
    local github_token="$GITHUB_TOKEN"
    
    # GitHub 이슈 목록 조회
    local issues=$(curl -s -H "Authorization: token $github_token" \
                       "https://api.github.com/repos/$github_repo/issues?state=open")
    
    # 각 이슈를 Plane으로 생성
    echo "$issues" | jq -r '.[] | @base64' | while read encoded_issue; do
        local issue=$(echo "$encoded_issue" | base64 --decode)
        local title=$(echo "$issue" | jq -r '.title')
        local body=$(echo "$issue" | jq -r '.body // ""')
        local github_id=$(echo "$issue" | jq -r '.number')
        
        # Plane에 이슈 생성 (GitHub ID를 설명에 포함)
        plane_issue "$title" "GitHub Issue #$github_id\n\n$body"
    done
}

# 간단 대시보드 출력
plane_dashboard() {
    echo "🎯 Plane 프로젝트 대시보드"
    echo "=========================="
    
    # 이슈 상태별 개수
    local issues=$(plane_api GET "/workspaces/$PLANE_WORKSPACE_ID/projects/$PLANE_PROJECT_ID/issues/")
    echo "📊 이슈 현황:"
    echo "$issues" | jq -r 'group_by(.state_detail.name) | .[] | "  \(.[0].state_detail.name): \(length)개"'
    
    # 최근 생성된 이슈 5개
    echo -e "\n📝 최근 이슈 (5개):"
    echo "$issues" | jq -r 'sort_by(.created_at) | reverse | .[0:5] | .[] | "  • \(.name) (\(.state_detail.name))"'
    
    # 내가 담당한 이슈
    local my_user_id=$(plane_api GET "/users/me/" | jq -r '.id')
    echo -e "\n👤 내 할당 이슈:"
    echo "$issues" | jq -r --arg uid "$my_user_id" '.[] | select(.assignees[]? == $uid) | "  • \(.name) (\(.state_detail.name))"'
}
```

## GitHub Webhooks 자동화

### 1. Webhook 서버 구성

```python
# webhook_server.py
from flask import Flask, request, jsonify
import requests
import os
import hmac
import hashlib

app = Flask(__name__)

PLANE_API_TOKEN = os.getenv('PLANE_API_TOKEN')
PLANE_API_BASE = os.getenv('PLANE_API_BASE')
WORKSPACE_ID = os.getenv('PLANE_WORKSPACE_ID')
PROJECT_ID = os.getenv('PLANE_PROJECT_ID')
WEBHOOK_SECRET = os.getenv('GITHUB_WEBHOOK_SECRET')

def verify_signature(payload, signature):
    """GitHub Webhook 서명 검증"""
    expected = hmac.new(
        WEBHOOK_SECRET.encode(),
        payload,
        hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(f"sha256={expected}", signature)

def create_plane_issue(title, description, labels=None):
    """Plane에 이슈 생성"""
    headers = {
        'Authorization': f'Bearer {PLANE_API_TOKEN}',
        'Content-Type': 'application/json'
    }
    
    data = {
        'name': title,
        'description': description,
        'labels': labels or []
    }
    
    response = requests.post(
        f"{PLANE_API_BASE}/workspaces/{WORKSPACE_ID}/projects/{PROJECT_ID}/issues/",
        headers=headers,
        json=data
    )
    return response.json()

@app.route('/github/webhook', methods=['POST'])
def github_webhook():
    signature = request.headers.get('X-Hub-Signature-256')
    if not verify_signature(request.data, signature):
        return jsonify({'error': 'Invalid signature'}), 403
    
    event_type = request.headers.get('X-GitHub-Event')
    payload = request.json
    
    if event_type == 'issues' and payload['action'] == 'opened':
        # 새 GitHub 이슈가 생성되면 Plane에도 생성
        issue = payload['issue']
        title = f"[GitHub] {issue['title']}"
        description = f"GitHub Issue #{issue['number']}\n\n{issue['body']}"
        labels = [label['name'] for label in issue['labels']]
        
        plane_issue = create_plane_issue(title, description, labels)
        return jsonify({'plane_issue_id': plane_issue.get('id')})
    
    elif event_type == 'push':
        # 커밋 메시지에서 이슈 번호 추출하여 자동 상태 변경
        for commit in payload['commits']:
            message = commit['message']
            # "fixes #123", "closes #456" 형태의 메시지 처리
            import re
            issues = re.findall(r'(?:fixes|closes|resolves)\s+#(\d+)', message, re.IGNORECASE)
            
            for issue_id in issues:
                # Plane 이슈 상태를 'Done'으로 변경
                update_issue_status(issue_id, 'Done')
    
    return jsonify({'status': 'processed'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

### 2. Docker로 Webhook 서버 실행

```dockerfile
# Dockerfile.webhook
FROM python:3.11-alpine

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY webhook_server.py .

EXPOSE 5000
CMD ["python", "webhook_server.py"]
```

```yaml
# docker-compose.webhook.yml에 추가
webhook-server:
  build:
    context: .
    dockerfile: Dockerfile.webhook
  ports:
    - "5000:5000"
  environment:
    - PLANE_API_TOKEN=${PLANE_API_TOKEN}
    - PLANE_API_BASE=${PLANE_API_BASE}
    - PLANE_WORKSPACE_ID=${PLANE_WORKSPACE_ID}
    - PLANE_PROJECT_ID=${PLANE_PROJECT_ID}
    - GITHUB_WEBHOOK_SECRET=${GITHUB_WEBHOOK_SECRET}
  restart: unless-stopped
```

## 창의적인 자동화 예제들

### 1. 커밋 기반 자동 시간 추적

```bash
# Git hook: .git/hooks/post-commit
#!/bin/bash

# 커밋 메시지에서 시간 정보 추출
commit_message=$(git log -1 --pretty=%B)
time_spent=$(echo "$commit_message" | grep -oE 'time:([0-9]+[hm])' | cut -d: -f2)

if [ -n "$time_spent" ]; then
    # 현재 브랜치에서 이슈 번호 추출 (예: feature/issue-123)
    branch_name=$(git branch --show-current)
    issue_id=$(echo "$branch_name" | grep -oE 'issue-([0-9]+)' | cut -d- -f2)
    
    if [ -n "$issue_id" ]; then
        # Plane에 시간 기록 추가
        plane_api POST "/workspaces/$PLANE_WORKSPACE_ID/projects/$PLANE_PROJECT_ID/issues/$issue_id/time-logs/" \
        "{\"time_spent\": \"$time_spent\", \"description\": \"$commit_message\"}"
        
        echo "✅ 시간 추적이 기록되었습니다: $time_spent"
    fi
fi
```

### 2. AI 기반 이슈 우선순위 자동 설정

{% raw %}
```python
# priority_ai.py
import openai
import requests
import json

def analyze_issue_priority(title, description):
    """OpenAI를 사용하여 이슈 우선순위 분석"""
    prompt = f"""
    다음 이슈의 우선순위를 urgent, high, medium, low 중에서 결정해주세요:
    
    제목: {title}
    설명: {description}
    
    JSON 형태로 응답해주세요: `"priority": "medium", "reason": "이유"`
    """
    
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}]
    )
    
    return json.loads(response.choices[0].message.content)

def auto_prioritize_issues():
    """모든 이슈의 우선순위를 AI로 자동 설정"""
    issues = requests.get(
        f"{PLANE_API_BASE}/workspaces/{WORKSPACE_ID}/projects/{PROJECT_ID}/issues/",
        headers={'Authorization': f'Bearer {PLANE_API_TOKEN}'}
    ).json()
    
    for issue in issues:
        if not issue.get('priority'):  # 우선순위가 설정되지 않은 이슈만
            analysis = analyze_issue_priority(issue['name'], issue['description'])
            
            # 우선순위 업데이트
            requests.patch(
                f"{PLANE_API_BASE}/workspaces/{WORKSPACE_ID}/projects/{PROJECT_ID}/issues/{issue['id']}/",
                headers={'Authorization': f'Bearer {PLANE_API_TOKEN}'},
                json={'priority': analysis['priority']}
            )
            
            print(f"✅ {issue['name']}: {analysis['priority']} ({analysis['reason']})")
```
{% endraw %}

### 3. Slack 통합 알림 시스템

```bash
# slack_notify.sh
#!/bin/bash

slack_notify() {
    local message="$1"
    local channel="${2:-#dev-team}"
    local webhook_url="$SLACK_WEBHOOK_URL"
    
    curl -X POST -H 'Content-type: application/json' \
         --data "{\"channel\":\"$channel\",\"text\":\"$message\"}" \
         "$webhook_url"
}

# 새 이슈 생성 시 Slack 알림
plane_issue_with_slack() {
    local title="$1"
    local description="$2"
    local assignee="$3"
    
    # Plane에 이슈 생성
    local result=$(plane_issue "$title" "$description")
    local issue_id=$(echo "$result" | jq -r '.id')
    
    # 담당자 할당
    if [ -n "$assignee" ]; then
        plane_assign_issue "$issue_id" "$assignee"
    fi
    
    # Slack 알림
    local message="🎯 새 이슈가 생성되었습니다!\n*$title*\n담당자: $assignee\n링크: https://your-plane-domain.com/projects/$PLANE_PROJECT_ID/issues/$issue_id"
    slack_notify "$message"
}

# 스프린트 완료 리포트
plane_sprint_report() {
    local cycle_id="$1"
    
    # 사이클 정보 조회
    local cycle_info=$(plane_api GET "/workspaces/$PLANE_WORKSPACE_ID/projects/$PLANE_PROJECT_ID/cycles/$cycle_id/")
    local cycle_name=$(echo "$cycle_info" | jq -r '.name')
    
    # 완료된 이슈 수 계산
    local completed_issues=$(plane_api GET "/workspaces/$PLANE_WORKSPACE_ID/projects/$PLANE_PROJECT_ID/cycles/$cycle_id/issues/" | \
                            jq '[.[] | select(.state_detail.group == "completed")] | length')
    
    local total_issues=$(plane_api GET "/workspaces/$PLANE_WORKSPACE_ID/projects/$PLANE_PROJECT_ID/cycles/$cycle_id/issues/" | jq 'length')
    
    local completion_rate=$((completed_issues * 100 / total_issues))
    
    # Slack 리포트 전송
    local report="📊 *$cycle_name* 완료 리포트\n완료율: $completion_rate% ($completed_issues/$total_issues)\n"
    slack_notify "$report" "#management"
}
```

## 실무 워크플로우 예제

### 1. 완전한 개발 워크플로우

```bash
# 새 기능 개발 시작
start_feature() {
    local feature_name="$1"
    local description="$2"
    
    # 1. Plane에 이슈 생성
    local issue_result=$(plane_issue "[Feature] $feature_name" "$description" "high")
    local issue_id=$(echo "$issue_result" | grep -oE 'ID: [a-z0-9-]+' | cut -d' ' -f2)
    
    # 2. Git 브랜치 생성
    git checkout -b "feature/issue-$issue_id"
    
    # 3. 이슈를 현재 스프린트에 추가
    local current_cycle=$(plane_api GET "/workspaces/$PLANE_WORKSPACE_ID/projects/$PLANE_PROJECT_ID/cycles/" | \
                         jq -r '.[] | select(.is_current == true) | .id')
    plane_api POST "/workspaces/$PLANE_WORKSPACE_ID/projects/$PLANE_PROJECT_ID/cycles/$current_cycle/cycle-issues/" \
              "{\"issues\": [\"$issue_id\"]}"
    
    # 4. 이슈 상태를 'In Progress'로 변경
    plane_move "$issue_id" "In Progress"
    
    # 5. Slack 알림
    slack_notify "🚀 새 기능 개발 시작: *$feature_name*\n이슈 ID: $issue_id"
    
    echo "✅ 개발 환경이 준비되었습니다!"
    echo "   이슈 ID: $issue_id"
    echo "   브랜치: feature/issue-$issue_id"
}

# 기능 완료 및 배포
finish_feature() {
    local commit_message="$1"
    
    # 현재 브랜치에서 이슈 ID 추출
    local branch_name=$(git branch --show-current)
    local issue_id=$(echo "$branch_name" | grep -oE 'issue-([a-z0-9-]+)' | cut -d- -f2)
    
    if [ -n "$issue_id" ]; then
        # 1. 커밋 및 푸시
        git add .
        git commit -m "$commit_message (fixes #$issue_id time:2h)"
        git push origin "$branch_name"
        
        # 2. PR 생성 (GitHub CLI 사용)
        gh pr create --title "Feature: $(plane_api GET "/workspaces/$PLANE_WORKSPACE_ID/projects/$PLANE_PROJECT_ID/issues/$issue_id/" | jq -r '.name')" \
                     --body "Closes #$issue_id"
        
        # 3. 이슈 상태를 'In Review'로 변경
        plane_move "$issue_id" "In Review"
        
        # 4. 리뷰어에게 알림
        slack_notify "👀 코드 리뷰 요청: $(git log -1 --pretty=%s)\nPR: $(gh pr view --json url -q .url)"
        
        echo "✅ 기능 개발이 완료되고 리뷰 요청이 전송되었습니다!"
    fi
}
```

### 2. 데일리 스탠드업 자동화

```bash
# daily_standup.sh
#!/bin/bash

generate_daily_standup() {
    local team_members=("user_id_1" "user_id_2" "user_id_3")
    local today=$(date -I)
    local yesterday=$(date -I -d '1 day ago')
    
    echo "📅 Daily Standup Report - $today"
    echo "=================================="
    
    for user_id in "${team_members[@]}"; do
        # 사용자 정보 조회
        local user_info=$(plane_api GET "/users/$user_id/")
        local user_name=$(echo "$user_info" | jq -r '.display_name')
        
        echo -e "\n👤 **$user_name**"
        
        # 어제 완료한 작업
        local completed_yesterday=$(plane_api GET "/workspaces/$PLANE_WORKSPACE_ID/projects/$PLANE_PROJECT_ID/issues/" | \
                                   jq -r --arg uid "$user_id" --arg date "$yesterday" \
                                   '.[] | select(.assignees[]? == $uid and .completed_at[0:10] == $date) | "  ✅ \(.name)"')
        
        if [ -n "$completed_yesterday" ]; then
            echo "  어제 완료:"
            echo "$completed_yesterday"
        else
            echo "  어제 완료: 없음"
        fi
        
        # 오늘 진행 중인 작업
        local in_progress=$(plane_api GET "/workspaces/$PLANE_WORKSPACE_ID/projects/$PLANE_PROJECT_ID/issues/" | \
                           jq -r --arg uid "$user_id" \
                           '.[] | select(.assignees[]? == $uid and .state_detail.group == "started") | "  🔄 \(.name)"')
        
        if [ -n "$in_progress" ]; then
            echo "  진행 중:"
            echo "$in_progress"
        else
            echo "  진행 중: 없음"
        fi
        
        # 블로커 확인
        local blocked=$(plane_api GET "/workspaces/$PLANE_WORKSPACE_ID/projects/$PLANE_PROJECT_ID/issues/" | \
                       jq -r --arg uid "$user_id" \
                       '.[] | select(.assignees[]? == $uid and (.labels[]? == "blocked" or .priority == "urgent")) | "  🚫 \(.name)"')
        
        if [ -n "$blocked" ]; then
            echo "  블로커:"
            echo "$blocked"
        fi
    done
    
    # Slack으로 전송
    local report=$(generate_daily_standup)
    slack_notify "$report" "#daily-standup"
}

# 크론잡으로 매일 오전 9시에 실행
# 0 9 * * 1-5 /path/to/daily_standup.sh
```

### 3. 릴리즈 노트 자동 생성

```python
# release_notes.py
import requests
import json
from datetime import datetime, timedelta

def generate_release_notes(version, since_date=None):
    """특정 기간의 완료된 이슈들로부터 릴리즈 노트 생성"""
    
    if not since_date:
        since_date = (datetime.now() - timedelta(days=14)).isoformat()
    
    # 완료된 이슈들 조회
    issues_response = requests.get(
        f"{PLANE_API_BASE}/workspaces/{WORKSPACE_ID}/projects/{PROJECT_ID}/issues/",
        headers={'Authorization': f'Bearer {PLANE_API_TOKEN}'},
        params={
            'state_group': 'completed',
            'completed_at__gte': since_date
        }
    )
    
    issues = issues_response.json()
    
    # 카테고리별로 분류
    features = []
    bug_fixes = []
    improvements = []
    
    for issue in issues:
        labels = [label['name'].lower() for label in issue.get('labels', [])]
        
        if 'feature' in labels or issue['name'].lower().startswith('[feature]'):
            features.append(issue)
        elif 'bug' in labels or 'fix' in labels:
            bug_fixes.append(issue)
        else:
            improvements.append(issue)
    
    # 릴리즈 노트 생성
    release_notes = f"""# Release {version}
    
Released: {datetime.now().strftime('%Y-%m-%d')}

## 🚀 New Features
"""
    
    for feature in features:
        release_notes += f"- {feature['name']} (#{feature['sequence_id']})\n"
    
    if bug_fixes:
        release_notes += "\n## 🐛 Bug Fixes\n"
        for bug in bug_fixes:
            release_notes += f"- {bug['name']} (#{bug['sequence_id']})\n"
    
    if improvements:
        release_notes += "\n## ✨ Improvements\n"
        for improvement in improvements:
            release_notes += f"- {improvement['name']} (#{improvement['sequence_id']})\n"
    
    # 통계 추가
    release_notes += f"""
## 📊 Statistics
- Total Issues Resolved: {len(issues)}
- Features: {len(features)}
- Bug Fixes: {len(bug_fixes)}
- Improvements: {len(improvements)}
"""
    
    return release_notes

# GitHub Release 생성
def create_github_release(version, release_notes, repo):
    """GitHub에 릴리즈 생성"""
    release_data = {
        'tag_name': f'v{version}',
        'name': f'Release {version}',
        'body': release_notes,
        'draft': False,
        'prerelease': False
    }
    
    response = requests.post(
        f'https://api.github.com/repos/{repo}/releases',
        headers={
            'Authorization': f'token {GITHUB_TOKEN}',
            'Accept': 'application/vnd.github.v3+json'
        },
        json=release_data
    )
    
    return response.json()

if __name__ == '__main__':
    import sys
    version = sys.argv[1] if len(sys.argv) > 1 else '1.0.0'
    notes = generate_release_notes(version)
    print(notes)
```

## 유용한 팁과 트릭

### 1. 환경 변수 관리

```bash
# ~/.plane_env
export PLANE_API_TOKEN="your_token_here"
export PLANE_API_BASE="https://your-domain.com/api/v1" 
export PLANE_WORKSPACE_ID="workspace_id"
export PLANE_PROJECT_ID="project_id"
export GITHUB_TOKEN="github_token"
export SLACK_WEBHOOK_URL="slack_webhook_url"

# ~/.zshrc에 추가
[ -f ~/.plane_env ] && source ~/.plane_env
```

### 2. JSON 데이터 템플릿

```bash
# issue_templates.sh
create_bug_report() {
    local title="$1"
    local steps="$2"
    local expected="$3"
    local actual="$4"
    
    local description=$(cat <<EOF
## 🐛 Bug Report

### Steps to Reproduce
$steps

### Expected Behavior
$expected

### Actual Behavior
$actual

### Environment
- OS: $(uname -s)
- Browser: $(echo $USER_AGENT)
- Date: $(date)
EOF
)
    
    plane_issue "🐛 $title" "$description" "high"
}

create_feature_request() {
    local title="$1"
    local user_story="$2"
    local acceptance_criteria="$3"
    
    local description=$(cat <<EOF
## 🚀 Feature Request

### User Story
$user_story

### Acceptance Criteria
$acceptance_criteria

### Additional Context
- Priority: Medium
- Estimated effort: TBD
EOF
)
    
    plane_issue "🚀 $title" "$description" "medium"
}
```

### 3. 배치 작업 스크립트

```bash
# batch_operations.sh

# 모든 이슈에 라벨 일괄 적용
bulk_add_label() {
    local label_id="$1"
    local filter="$2"  # 예: "priority=high"
    
    local issues=$(plane_api GET "/workspaces/$PLANE_WORKSPACE_ID/projects/$PLANE_PROJECT_ID/issues/?$filter")
    
    echo "$issues" | jq -r '.[].id' | while read issue_id; do
        plane_api POST "/workspaces/$PLANE_WORKSPACE_ID/projects/$PLANE_PROJECT_ID/issues/$issue_id/issue-labels/" \
                  "{\"labels\": [\"$label_id\"]}"
        echo "✅ 라벨이 $issue_id에 추가되었습니다."
    done
}

# 완료된 이슈들을 아카이브로 이동
archive_completed_issues() {
    local days_ago="${1:-30}"  # 기본 30일 전
    local cutoff_date=$(date -I -d "$days_ago days ago")
    
    local completed_issues=$(plane_api GET "/workspaces/$PLANE_WORKSPACE_ID/projects/$PLANE_PROJECT_ID/issues/" | \
                            jq -r --arg date "$cutoff_date" \
                            '.[] | select(.state_detail.group == "completed" and .completed_at[0:10] < $date) | .id')
    
    echo "$completed_issues" | while read issue_id; do
        plane_api PATCH "/workspaces/$PLANE_WORKSPACE_ID/projects/$PLANE_PROJECT_ID/issues/$issue_id/" \
                  '{"archived_at": "'$(date -Iseconds)'"}'
        echo "📦 이슈 $issue_id가 아카이브되었습니다."
    done
}
```

## 모니터링과 알림

### 1. 프로젝트 건강도 체크

```bash
# health_check.sh
#!/bin/bash

project_health_check() {
    local issues=$(plane_api GET "/workspaces/$PLANE_WORKSPACE_ID/projects/$PLANE_PROJECT_ID/issues/")
    
    # 기본 통계
    local total_issues=$(echo "$issues" | jq 'length')
    local overdue_issues=$(echo "$issues" | jq --arg today "$(date -I)" \
                          '[.[] | select(.target_date != null and .target_date < $today and .state_detail.group != "completed")] | length')
    local unassigned_issues=$(echo "$issues" | jq '[.[] | select(.assignees | length == 0)] | length')
    local high_priority_open=$(echo "$issues" | jq '[.[] | select(.priority == "urgent" or .priority == "high") | select(.state_detail.group != "completed")] | length')
    
    # 건강도 점수 계산 (100점 만점)
    local health_score=100
    
    # 과도한 미할당 이슈
    if [ $unassigned_issues -gt $((total_issues / 4)) ]; then
        health_score=$((health_score - 20))
    fi
    
    # 연체된 이슈
    if [ $overdue_issues -gt 0 ]; then
        health_score=$((health_score - overdue_issues * 5))
    fi
    
    # 높은 우선순위 이슈가 너무 많음
    if [ $high_priority_open -gt $((total_issues / 3)) ]; then
        health_score=$((health_score - 15))
    fi
    
    # 최소 점수 보장
    [ $health_score -lt 0 ] && health_score=0
    
    # 결과 출력
    local status_emoji="✅"
    [ $health_score -lt 70 ] && status_emoji="⚠️"
    [ $health_score -lt 50 ] && status_emoji="🚨"
    
    local report=$(cat <<EOF
$status_emoji **프로젝트 건강도 리포트** 
점수: $health_score/100

📊 **통계**
- 전체 이슈: $total_issues개
- 연체된 이슈: $overdue_issues개  
- 미할당 이슈: $unassigned_issues개
- 높은 우선순위 (미완료): $high_priority_open개

🎯 **권장사항**
EOF
)
    
    if [ $overdue_issues -gt 0 ]; then
        report="$report\n- 연체된 이슈 $overdue_issues개를 우선 처리하세요"
    fi
    
    if [ $unassigned_issues -gt 5 ]; then
        report="$report\n- 미할당 이슈 $unassigned_issues개에 담당자를 지정하세요"
    fi
    
    echo -e "$report"
    
    # 심각한 상황일 때 알림
    if [ $health_score -lt 50 ]; then
        slack_notify "$report" "#alerts"
    fi
}

# 매일 오전 8시에 건강도 체크
# 0 8 * * * /path/to/health_check.sh
```

## 시리즈 연결

이 글은 **Plane 완전 정복 시리즈**의 두 번째 글입니다:

### 시리즈 목록
1. **[Plane 프로젝트 관리 도구 완전 가이드](#)** - 기본 설치와 설정
2. **Plane GitHub 연동 완전 정복** *(현재 글)* - API 자동화와 워크플로우 최적화  
3. **Plane 고급 커스터마이징과 확장** *(예정)* - 플러그인 개발과 고급 설정

## 결론

Plane과 GitHub의 완벽한 연동을 통해 **개발 생산성을 극대화**할 수 있는 다양한 방법들을 살펴봤습니다. 단순한 이슈 추적을 넘어서 **스마트한 자동화**로 팀의 워크플로우를 혁신할 수 있습니다.

### 🚀 핵심 성과

1. **시간 절약**: 터미널 alias로 반복 작업을 90% 단축
2. **자동화**: GitHub Webhooks로 수동 동기화 작업 제거  
3. **통합 워크플로우**: 개발부터 배포까지 끊김없는 연결
4. **팀 협업**: Slack 통합으로 실시간 소통 강화
5. **데이터 기반 의사결정**: 자동 리포트로 프로젝트 건강도 모니터링

### 💡 다음 단계

이제 여러분의 프로젝트에 이 가이드를 적용해보세요:

```bash
# 환경 설정
source ~/.plane_env

# 첫 번째 자동화된 이슈 생성
pi "API 자동화 테스트" "GitHub 연동 스크립트 테스트용 이슈입니다."

# 대시보드 확인  
pdash

# 팀에게 공유
slack_notify "🎉 Plane 자동화가 설정되었습니다! 이제 더 스마트하게 일할 수 있어요."
```

**36.9k⭐ GitHub 스타**를 받은 Plane에 이런 자동화 기능까지 더해지면, 정말 강력한 프로젝트 관리 환경을 구축할 수 있습니다. 

다음 시리즈에서는 **Plane 플러그인 개발**과 **고급 커스터마이징**을 다룰 예정입니다. 더 궁금한 점이 있으시면 댓글로 남겨주세요! 

---

**🔗 참고 자료**
- [Plane API 문서](https://docs.plane.so/api-reference)
- [GitHub Webhooks 가이드](https://docs.github.com/en/developers/webhooks-and-events/webhooks)
- [첫 번째 시리즈: Plane 기본 가이드](#) 