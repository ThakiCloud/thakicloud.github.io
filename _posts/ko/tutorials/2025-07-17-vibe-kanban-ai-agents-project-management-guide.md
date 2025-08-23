---
title: "Vibe Kanban 완전 가이드 - AI 에이전트와 GitHub 프로젝트 통합 운영법"
excerpt: "BloopAI의 Vibe Kanban을 활용하여 AI 코딩 에이전트들을 효율적으로 관리하고, 기존 GitHub 프로젝트와 완벽하게 통합하는 방법을 상세히 설명합니다."
seo_title: "Vibe Kanban 튜토리얼 - AI 에이전트 프로젝트 관리 완전 가이드 - Thaki Cloud"
seo_description: "BloopAI Vibe Kanban으로 Claude Code, Gemini CLI 등 AI 에이전트를 관리하고 GitHub 프로젝트와 통합하는 실무 가이드. Apache-2.0 라이선스 분석 포함."
date: 2025-07-17
last_modified_at: 2025-07-17
categories:
  - tutorials
  - agentops
tags:
  - Vibe-Kanban
  - BloopAI
  - AI-에이전트
  - 칸반보드
  - Claude-Code
  - Gemini-CLI
  - 프로젝트-관리
  - Apache-2.0
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/vibe-kanban-ai-agents-project-management-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 18분

## 서론

**Vibe Kanban**은 BloopAI에서 개발한 혁신적인 AI 에이전트 관리 도구로, Claude Code, Gemini CLI, Codex, Amp 등 다양한 AI 코딩 에이전트들을 칸반 보드 형태로 체계적으로 관리할 수 있는 플랫폼입니다.

기존의 단순한 할 일 관리와 달리, Vibe Kanban은 **AI 에이전트들 간의 협업과 작업 흐름을 시각화**하여 복잡한 개발 프로젝트를 효율적으로 관리할 수 있게 해줍니다. 특히 GitHub 프로젝트와의 완벽한 통합을 통해 실제 개발 워크플로우에 자연스럽게 녹아들 수 있습니다.

이 가이드에서는 Vibe Kanban의 설치부터 고급 활용법까지, 그리고 기존 GitHub 프로젝트와 함께 운영하는 실무적인 방법들을 상세히 다루겠습니다.

## 📄 라이선스 분석 및 상업적 사용 가능성

### Apache-2.0 라이선스 개요

Vibe Kanban은 **Apache License 2.0**을 사용합니다. 이는 매우 관대한 오픈소스 라이선스로, 상업적 활용에 대한 제약이 거의 없습니다.

### 상업적 사용 가능성 매트릭스

| 사용 시나리오 | 허용 여부 | 소스코드 공개 의무 | 추가 조건 |
|---------------|-----------|-------------------|-----------|
| **개인 사용** | ✅ **완전 허용** | ❌ **불필요** | 없음 |
| **기업 내부 사용** | ✅ **완전 허용** | ❌ **불필요** | 없음 |
| **수정 후 배포** | ✅ **완전 허용** | ❌ **불필요** | 라이선스 고지만 필요 |
| **상용 제품 임베딩** | ✅ **완전 허용** | ❌ **불필요** | 라이선스 고지만 필요 |
| **클라우드 서비스** | ✅ **완전 허용** | ❌ **불필요** | 라이선스 고지만 필요 |

### 🏢 기업 환경 권장 사용 방식

```yaml
권장사항:
  상업적_사용: "완전 자유 - 어떤 제약도 없음"
  수정_배포: "자유롭게 가능"
  특허_보호: "Apache-2.0 특허 보호 조항 적용"
  
준수사항:
  라이선스_고지: "배포 시 LICENSE 파일 포함"
  저작권_표시: "원본 저작권 고지 유지"
  변경사항_표시: "수정 사항이 있다면 NOTICE 파일에 기록"
```

## 🚀 Vibe Kanban 설치 및 환경 구성

### 시스템 요구사항

#### 최소 요구사항
```
- Node.js: 18.0+ 
- npm: 9.0+ 또는 yarn: 1.22+
- OS: Windows 10+, macOS 10.15+, Linux (Ubuntu 20.04+)
- RAM: 4GB 이상
- 디스크: 1GB 여유 공간
```

#### 권장 사양
```
- Node.js: 20.0+ (LTS)
- npm: 10.0+ 또는 yarn: 4.0+
- OS: 최신 버전
- RAM: 8GB 이상
- 디스크: SSD 권장
```

### 빠른 설치 (npx 사용)

#### 1. 즉시 실행
```bash
# npx를 통한 즉시 실행
npx vibe-kanban

# 특정 포트로 실행
npx vibe-kanban --port 3001

# 설정 파일 지정
npx vibe-kanban --config ./custom-config.json
```

#### 2. 전역 설치
```bash
# npm 전역 설치
npm install -g vibe-kanban

# yarn 전역 설치
yarn global add vibe-kanban

# 설치 확인
vibe-kanban --version

# 도움말 확인
vibe-kanban --help
```

### 프로젝트별 설치

#### 1. 기존 프로젝트에 추가
```bash
# 기존 프로젝트 디렉토리로 이동
cd your-existing-project

# 개발 의존성으로 설치
npm install --save-dev vibe-kanban

# 또는 yarn 사용
yarn add --dev vibe-kanban

# package.json에 스크립트 추가
cat >> package.json << 'EOF'
{
  "scripts": {
    "kanban": "vibe-kanban",
    "kanban:dev": "vibe-kanban --watch",
    "kanban:prod": "vibe-kanban --port 8080 --config production.json"
  }
}
EOF
```

#### 2. 새 프로젝트 생성
```bash
# 새 프로젝트 디렉토리 생성
mkdir my-ai-project
cd my-ai-project

# npm 프로젝트 초기화
npm init -y

# Vibe Kanban 설치
npm install vibe-kanban

# 기본 설정 파일 생성
npx vibe-kanban init
```

## ⚙️ 설정 및 초기 구성

### 기본 설정 파일 생성

#### 1. 설정 디렉토리 구조
```bash
# 프로젝트 루트에 설정 디렉토리 생성
mkdir -p .vibe-kanban/{agents,workflows,templates}

# 기본 설정 파일 생성
cat > .vibe-kanban/config.json << 'EOF'
{
  "version": "1.0.0",
  "server": {
    "port": 3000,
    "host": "localhost",
    "cors": true
  },
  "agents": {
    "claude_code": {
      "enabled": true,
      "config_path": "./agents/claude-code.json"
    },
    "gemini_cli": {
      "enabled": true,
      "config_path": "./agents/gemini-cli.json"
    },
    "cursor": {
      "enabled": false,
      "config_path": "./agents/cursor.json"
    }
  },
  "workflows": {
    "default_board": "development",
    "auto_save": true,
    "sync_interval": 30
  },
  "github": {
    "integration": true,
    "webhook_url": "/api/github/webhook",
    "auto_create_tasks": true
  }
}
EOF
```

#### 2. AI 에이전트 설정
```json
# .vibe-kanban/agents/claude-code.json
{
  "name": "Claude Code",
  "type": "claude_code",
  "version": "1.0.0",
  "config": {
    "api_key_env": "ANTHROPIC_API_KEY",
    "model": "claude-3-5-sonnet-20241022",
    "max_tokens": 8192,
    "temperature": 0.1,
    "system_prompt": "You are a senior software engineer focused on writing clean, maintainable code.",
    "file_extensions": [".js", ".ts", ".py", ".go", ".rs"],
    "excluded_dirs": ["node_modules", ".git", "dist", "build"]
  },
  "capabilities": [
    "code_generation",
    "code_review",
    "debugging",
    "refactoring",
    "documentation"
  ],
  "workflow_hooks": {
    "pre_task": "analyze_context",
    "post_task": "validate_output",
    "on_error": "suggest_fix"
  }
}
```

```json
# .vibe-kanban/agents/gemini-cli.json
{
  "name": "Gemini CLI",
  "type": "gemini_cli",
  "version": "1.0.0",
  "config": {
    "api_key_env": "GEMINI_API_KEY",
    "model": "gemini-2.0-flash-exp",
    "max_output_tokens": 8192,
    "temperature": 0.2,
    "safety_settings": {
      "HARM_CATEGORY_HARASSMENT": "BLOCK_NONE",
      "HARM_CATEGORY_HATE_SPEECH": "BLOCK_NONE",
      "HARM_CATEGORY_SEXUALLY_EXPLICIT": "BLOCK_NONE",
      "HARM_CATEGORY_DANGEROUS_CONTENT": "BLOCK_NONE"
    }
  },
  "capabilities": [
    "multimodal_analysis",
    "image_generation",
    "code_explanation",
    "system_design"
  ],
  "workflow_hooks": {
    "pre_task": "load_context",
    "post_task": "save_artifacts"
  }
}
```

### 워크플로우 템플릿 설정

#### 1. 개발 워크플로우 템플릿
```yaml
# .vibe-kanban/workflows/development.yaml
name: "Development Workflow"
description: "Standard software development workflow with AI agents"

boards:
  - name: "Backlog"
    description: "Ideas and future tasks"
    automation:
      - trigger: "new_github_issue"
        action: "create_task"
        agent: "claude_code"
        
  - name: "Planning"
    description: "Tasks being planned and analyzed"
    automation:
      - trigger: "task_moved_here"
        action: "analyze_requirements"
        agent: "claude_code"
        
  - name: "In Progress"
    description: "Currently being worked on"
    wip_limit: 3
    automation:
      - trigger: "task_moved_here"
        action: "start_coding"
        agent: "claude_code"
        
  - name: "Review"
    description: "Code review and quality check"
    automation:
      - trigger: "task_moved_here"
        action: "code_review"
        agent: "gemini_cli"
        
  - name: "Testing"
    description: "Testing and validation"
    automation:
      - trigger: "task_moved_here"
        action: "run_tests"
        agent: "claude_code"
        
  - name: "Done"
    description: "Completed tasks"
    automation:
      - trigger: "task_moved_here"
        action: "close_github_issue"
        
task_types:
  - name: "Feature"
    color: "#0066cc"
    estimated_time: "2-5 days"
    
  - name: "Bug Fix"
    color: "#cc0000"
    estimated_time: "1-2 days"
    
  - name: "Documentation"
    color: "#00cc66"
    estimated_time: "0.5-1 day"
    
  - name: "Refactoring"
    color: "#cc6600"
    estimated_time: "1-3 days"
```

#### 2. 리서치 워크플로우 템플릿
```yaml
# .vibe-kanban/workflows/research.yaml
name: "Research Workflow"
description: "AI-powered research and analysis workflow"

boards:
  - name: "Research Queue"
    description: "Topics to research"
    
  - name: "Data Collection"
    description: "Gathering information"
    automation:
      - trigger: "task_moved_here"
        action: "web_search"
        agent: "gemini_cli"
        
  - name: "Analysis"
    description: "Analyzing collected data"
    automation:
      - trigger: "task_moved_here"
        action: "analyze_data"
        agent: "claude_code"
        
  - name: "Documentation"
    description: "Creating research documentation"
    automation:
      - trigger: "task_moved_here"
        action: "create_report"
        agent: "claude_code"
        
  - name: "Published"
    description: "Completed research"
```

## 🔗 GitHub 프로젝트와의 통합

### GitHub 연동 설정

#### 1. GitHub App 생성 및 설정
```bash
# GitHub CLI 설치 (macOS)
brew install gh

# GitHub CLI 설치 (Ubuntu)
sudo apt install gh

# GitHub 로그인
gh auth login

# 새 GitHub App 생성 (웹 인터페이스에서)
echo "GitHub App 생성 단계:"
echo "1. https://github.com/settings/apps/new 접속"
echo "2. App 이름: 'Vibe Kanban Integration'"
echo "3. Homepage URL: http://localhost:3000"
echo "4. Webhook URL: http://localhost:3000/api/github/webhook"
echo "5. 권한 설정:"
echo "   - Issues: Read & Write"
echo "   - Pull requests: Read & Write"
echo "   - Repository contents: Read & Write"
echo "   - Repository metadata: Read"
```

#### 2. 환경 변수 설정
```bash
# .env 파일 생성
cat > .env << 'EOF'
# AI 에이전트 API 키
ANTHROPIC_API_KEY=your_anthropic_api_key_here
GEMINI_API_KEY=your_gemini_api_key_here
OPENAI_API_KEY=your_openai_api_key_here

# GitHub 통합
GITHUB_TOKEN=your_github_token_here
GITHUB_APP_ID=your_github_app_id
GITHUB_PRIVATE_KEY_PATH=./github-app-private-key.pem
GITHUB_WEBHOOK_SECRET=your_webhook_secret

# Vibe Kanban 설정
VIBE_KANBAN_PORT=3000
VIBE_KANBAN_HOST=localhost
VIBE_KANBAN_DB_PATH=./data/kanban.db
EOF

# .env 파일을 .gitignore에 추가
echo ".env" >> .gitignore
echo "data/" >> .gitignore
echo ".vibe-kanban/cache/" >> .gitignore
```

#### 3. GitHub 웹훅 설정
```javascript
// .vibe-kanban/github-integration.js
const crypto = require('crypto');

class GitHubIntegration {
  constructor(config) {
    this.config = config;
    this.webhookSecret = process.env.GITHUB_WEBHOOK_SECRET;
  }

  verifyWebhookSignature(payload, signature) {
    const expectedSignature = crypto
      .createHmac('sha256', this.webhookSecret)
      .update(payload)
      .digest('hex');
    return `sha256=${expectedSignature}` === signature;
  }

  async handleWebhook(event, payload) {
    switch (event) {
      case 'issues':
        return this.handleIssueEvent(payload);
      case 'pull_request':
        return this.handlePullRequestEvent(payload);
      case 'push':
        return this.handlePushEvent(payload);
      default:
        console.log(`Unhandled webhook event: ${event}`);
    }
  }

  async handleIssueEvent(payload) {
    const { action, issue, repository } = payload;
    
    if (action === 'opened') {
      // 새 이슈가 생성되면 칸반 보드에 태스크 생성
      const task = {
        id: `github-issue-${issue.number}`,
        title: issue.title,
        description: issue.body,
        type: this.detectTaskType(issue.labels),
        priority: this.detectPriority(issue.labels),
        assignee: issue.assignee?.login,
        github_issue: {
          number: issue.number,
          url: issue.html_url,
          repository: repository.full_name
        },
        board: 'Backlog',
        created_at: new Date().toISOString()
      };
      
      return this.createKanbanTask(task);
    }
  }

  detectTaskType(labels) {
    const labelMap = {
      'bug': 'Bug Fix',
      'enhancement': 'Feature',
      'feature': 'Feature',
      'documentation': 'Documentation',
      'refactoring': 'Refactoring'
    };
    
    for (const label of labels) {
      if (labelMap[label.name.toLowerCase()]) {
        return labelMap[label.name.toLowerCase()];
      }
    }
    return 'Feature';
  }

  detectPriority(labels) {
    const priorityMap = {
      'priority: critical': 'Critical',
      'priority: high': 'High',
      'priority: medium': 'Medium',
      'priority: low': 'Low'
    };
    
    for (const label of labels) {
      if (priorityMap[label.name.toLowerCase()]) {
        return priorityMap[label.name.toLowerCase()];
      }
    }
    return 'Medium';
  }

  async createKanbanTask(task) {
    // Vibe Kanban API를 통해 태스크 생성
    const response = await fetch('http://localhost:3000/api/tasks', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.VIBE_KANBAN_API_TOKEN}`
      },
      body: JSON.stringify(task)
    });
    
    return response.json();
  }
}

module.exports = GitHubIntegration;
```

### 프로젝트 구조 통합

#### 1. 기존 프로젝트와 통합된 디렉토리 구조
```
your-project/
├── .vibe-kanban/              # Vibe Kanban 설정
│   ├── config.json            # 메인 설정
│   ├── agents/                # AI 에이전트 설정
│   │   ├── claude-code.json
│   │   ├── gemini-cli.json
│   │   └── cursor.json
│   ├── workflows/             # 워크플로우 정의
│   │   ├── development.yaml
│   │   ├── research.yaml
│   │   └── maintenance.yaml
│   ├── templates/             # 태스크 템플릿
│   │   ├── feature.json
│   │   ├── bugfix.json
│   │   └── documentation.json
│   └── integrations/          # 외부 통합
│       ├── github.js
│       ├── slack.js
│       └── jira.js
├── src/                       # 기존 소스 코드
├── docs/                      # 문서
├── .github/                   # GitHub 설정
│   ├── workflows/             # GitHub Actions
│   │   ├── ci.yml
│   │   └── vibe-kanban-sync.yml
│   └── ISSUE_TEMPLATE/        # 이슈 템플릿
├── package.json
├── .env                       # 환경 변수
└── .gitignore
```

#### 2. GitHub Actions 워크플로우 연동
```yaml
# .github/workflows/vibe-kanban-sync.yml
name: Vibe Kanban Sync

on:
  issues:
    types: [opened, closed, labeled, unlabeled]
  pull_request:
    types: [opened, closed, merged]
  push:
    branches: [main, develop]

jobs:
  sync-kanban:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Start Vibe Kanban server
        run: |
          npm run kanban &
          sleep 10
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Sync with Kanban board
        run: node .vibe-kanban/scripts/github-sync.js
        env:
          GITHUB_EVENT_NAME: ${{ github.event_name }}
          GITHUB_EVENT_PATH: ${{ github.event_path }}
```

#### 3. 이슈 템플릿과 Kanban 연동
```yaml
# .github/ISSUE_TEMPLATE/feature_request.yml
name: Feature Request
description: Suggest a new feature for this project
title: "[FEATURE] "
labels: ["enhancement", "priority: medium"]
assignees: []

body:
  - type: markdown
    attributes:
      value: |
        ## 🚀 Feature Request
        이 이슈는 자동으로 Vibe Kanban 보드에 추가됩니다.

  - type: textarea
    id: description
    attributes:
      label: Feature Description
      description: 원하는 기능에 대해 자세히 설명해주세요.
      placeholder: 이 기능이 어떻게 작동해야 하는지 설명해주세요...
    validations:
      required: true

  - type: dropdown
    id: priority
    attributes:
      label: Priority
      description: 이 기능의 우선순위는?
      options:
        - Low
        - Medium
        - High
        - Critical
      default: 1
    validations:
      required: true

  - type: dropdown
    id: estimated_effort
    attributes:
      label: Estimated Effort
      description: 예상 작업 시간
      options:
        - "< 1 day"
        - "1-2 days"
        - "3-5 days"
        - "1-2 weeks"
        - "> 2 weeks"
      default: 2
    validations:
      required: true

  - type: checkboxes
    id: ai_agents
    attributes:
      label: AI Agents to Involve
      description: 이 작업에 참여할 AI 에이전트를 선택하세요
      options:
        - label: Claude Code (코드 생성 및 리뷰)
        - label: Gemini CLI (멀티모달 분석)
        - label: Cursor (통합 개발 환경)
```

## 🤖 AI 에이전트 설정 및 관리

### 에이전트별 세부 설정

#### 1. Claude Code 에이전트 고급 설정
```javascript
// .vibe-kanban/agents/claude-code-advanced.js
class ClaudeCodeAgent {
  constructor(config) {
    this.config = config;
    this.anthropic = new Anthropic({
      apiKey: process.env.ANTHROPIC_API_KEY
    });
  }

  async executeTask(task) {
    const context = await this.gatherContext(task);
    const prompt = this.buildPrompt(task, context);
    
    try {
      const response = await this.anthropic.messages.create({
        model: this.config.model,
        max_tokens: this.config.max_tokens,
        temperature: this.config.temperature,
        system: this.config.system_prompt,
        messages: [
          {
            role: 'user',
            content: prompt
          }
        ]
      });

      const result = await this.processResponse(response, task);
      await this.updateTask(task.id, result);
      
      return result;
    } catch (error) {
      await this.handleError(task.id, error);
      throw error;
    }
  }

  async gatherContext(task) {
    const context = {
      project_structure: await this.getProjectStructure(),
      related_files: await this.getRelatedFiles(task),
      github_issue: await this.getGitHubIssue(task),
      recent_commits: await this.getRecentCommits(),
      test_files: await this.getTestFiles(task)
    };

    return context;
  }

  buildPrompt(task, context) {
    return `
# Task: ${task.title}

## Description
${task.description}

## Context
### Project Structure
${JSON.stringify(context.project_structure, null, 2)}

### Related Files
${context.related_files.map(file => `- ${file.path}: ${file.summary}`).join('\n')}

### GitHub Issue
${context.github_issue ? `
- Issue #${context.github_issue.number}: ${context.github_issue.title}
- Labels: ${context.github_issue.labels.map(l => l.name).join(', ')}
- Assignee: ${context.github_issue.assignee?.login || 'Unassigned'}
` : 'No associated GitHub issue'}

### Recent Commits
${context.recent_commits.map(commit => `- ${commit.sha.substring(0, 7)}: ${commit.message}`).join('\n')}

## Instructions
1. Analyze the task and context thoroughly
2. Create a detailed implementation plan
3. Generate clean, well-documented code
4. Include appropriate tests
5. Update relevant documentation
6. Follow the project's coding standards

## Expected Output
Please provide:
1. Implementation plan (in JSON format)
2. Code changes (with file paths)
3. Test cases
4. Documentation updates
5. Summary of changes

Format your response as a structured JSON object.
`;
  }

  async processResponse(response, task) {
    const content = response.content[0].text;
    
    try {
      const parsed = JSON.parse(content);
      
      // 파일 변경사항 적용
      if (parsed.code_changes) {
        for (const change of parsed.code_changes) {
          await this.applyFileChange(change);
        }
      }

      // 테스트 실행
      if (parsed.test_cases) {
        const testResults = await this.runTests(parsed.test_cases);
        parsed.test_results = testResults;
      }

      // 문서 업데이트
      if (parsed.documentation_updates) {
        await this.updateDocumentation(parsed.documentation_updates);
      }

      return parsed;
    } catch (error) {
      console.error('Failed to parse Claude Code response:', error);
      return {
        error: 'Failed to parse response',
        raw_response: content
      };
    }
  }

  async applyFileChange(change) {
    const fs = require('fs').promises;
    const path = require('path');
    
    try {
      if (change.action === 'create') {
        await fs.mkdir(path.dirname(change.path), { recursive: true });
        await fs.writeFile(change.path, change.content, 'utf8');
      } else if (change.action === 'modify') {
        await fs.writeFile(change.path, change.content, 'utf8');
      } else if (change.action === 'delete') {
        await fs.unlink(change.path);
      }
      
      console.log(`Applied ${change.action} to ${change.path}`);
    } catch (error) {
      console.error(`Failed to apply change to ${change.path}:`, error);
      throw error;
    }
  }
}

module.exports = ClaudeCodeAgent;
```

#### 2. Gemini CLI 에이전트 설정
```javascript
// .vibe-kanban/agents/gemini-cli-advanced.js
class GeminiCLIAgent {
  constructor(config) {
    this.config = config;
    this.gemini = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
  }

  async executeTask(task) {
    const model = this.gemini.getGenerativeModel({ 
      model: this.config.model,
      generationConfig: {
        maxOutputTokens: this.config.max_output_tokens,
        temperature: this.config.temperature
      },
      safetySettings: this.config.safety_settings
    });

    const context = await this.gatherMultimodalContext(task);
    const prompt = this.buildMultimodalPrompt(task, context);

    try {
      const result = await model.generateContent(prompt);
      const processed = await this.processMultimodalResponse(result, task);
      await this.updateTask(task.id, processed);
      
      return processed;
    } catch (error) {
      await this.handleError(task.id, error);
      throw error;
    }
  }

  async gatherMultimodalContext(task) {
    const context = {
      text_context: await this.getTextContext(task),
      images: await this.getRelatedImages(task),
      diagrams: await this.getSystemDiagrams(task),
      screenshots: await this.getScreenshots(task)
    };

    return context;
  }

  buildMultimodalPrompt(task, context) {
    const promptParts = [
      {
        text: `
# Multimodal Task Analysis: ${task.title}

## Task Description
${task.description}

## Analysis Instructions
1. Analyze all provided visual materials
2. Extract key information from images/diagrams
3. Correlate visual information with text context
4. Provide comprehensive analysis and recommendations
5. Generate visual artifacts if needed

## Text Context
${JSON.stringify(context.text_context, null, 2)}
`
      }
    ];

    // 이미지 추가
    if (context.images.length > 0) {
      promptParts.push({ text: "\n## Related Images" });
      context.images.forEach((image, index) => {
        promptParts.push({
          inlineData: {
            mimeType: image.mimeType,
            data: image.data
          }
        });
        promptParts.push({ text: `Image ${index + 1}: ${image.description}` });
      });
    }

    // 다이어그램 추가
    if (context.diagrams.length > 0) {
      promptParts.push({ text: "\n## System Diagrams" });
      context.diagrams.forEach((diagram, index) => {
        promptParts.push({
          inlineData: {
            mimeType: diagram.mimeType,
            data: diagram.data
          }
        });
        promptParts.push({ text: `Diagram ${index + 1}: ${diagram.description}` });
      });
    }

    return promptParts;
  }

  async processMultimodalResponse(result, task) {
    const response = result.response.text();
    
    try {
      // 구조화된 응답 파싱
      const sections = this.parseResponseSections(response);
      
      // 이미지 생성이 필요한 경우
      if (sections.generate_images) {
        const generatedImages = await this.generateImages(sections.generate_images);
        sections.generated_artifacts = generatedImages;
      }

      // 다이어그램 생성이 필요한 경우
      if (sections.generate_diagrams) {
        const diagrams = await this.generateDiagrams(sections.generate_diagrams);
        sections.generated_diagrams = diagrams;
      }

      return {
        analysis: sections.analysis,
        recommendations: sections.recommendations,
        generated_artifacts: sections.generated_artifacts || [],
        generated_diagrams: sections.generated_diagrams || [],
        raw_response: response
      };
    } catch (error) {
      console.error('Failed to process Gemini response:', error);
      return {
        error: 'Failed to process multimodal response',
        raw_response: response
      };
    }
  }
}

module.exports = GeminiCLIAgent;
```

### 에이전트 간 협업 워크플로우

#### 1. 에이전트 체인 설정
```yaml
# .vibe-kanban/workflows/agent-chains.yaml
agent_chains:
  feature_development:
    name: "Feature Development Chain"
    description: "Complete feature development with multiple AI agents"
    steps:
      - agent: "gemini_cli"
        task: "analyze_requirements"
        inputs: ["github_issue", "user_stories"]
        outputs: ["requirements_analysis", "system_design"]
        
      - agent: "claude_code"
        task: "implement_feature"
        inputs: ["requirements_analysis", "system_design", "existing_codebase"]
        outputs: ["implementation", "unit_tests"]
        depends_on: ["analyze_requirements"]
        
      - agent: "gemini_cli"
        task: "review_implementation"
        inputs: ["implementation", "requirements_analysis"]
        outputs: ["code_review", "improvement_suggestions"]
        depends_on: ["implement_feature"]
        
      - agent: "claude_code"
        task: "apply_improvements"
        inputs: ["implementation", "improvement_suggestions"]
        outputs: ["final_implementation", "integration_tests"]
        depends_on: ["review_implementation"]
        
      - agent: "gemini_cli"
        task: "create_documentation"
        inputs: ["final_implementation", "requirements_analysis"]
        outputs: ["user_documentation", "technical_documentation"]
        depends_on: ["apply_improvements"]

  bug_fix:
    name: "Bug Fix Chain"
    description: "Systematic bug fixing with AI agents"
    steps:
      - agent: "gemini_cli"
        task: "analyze_bug_report"
        inputs: ["github_issue", "error_logs", "screenshots"]
        outputs: ["bug_analysis", "reproduction_steps"]
        
      - agent: "claude_code"
        task: "investigate_code"
        inputs: ["bug_analysis", "codebase", "test_results"]
        outputs: ["root_cause_analysis", "fix_proposal"]
        depends_on: ["analyze_bug_report"]
        
      - agent: "claude_code"
        task: "implement_fix"
        inputs: ["fix_proposal", "root_cause_analysis"]
        outputs: ["bug_fix", "regression_tests"]
        depends_on: ["investigate_code"]
        
      - agent: "gemini_cli"
        task: "validate_fix"
        inputs: ["bug_fix", "reproduction_steps", "test_results"]
        outputs: ["validation_report", "closure_recommendation"]
        depends_on: ["implement_fix"]
```

#### 2. 워크플로우 실행 엔진
```javascript
// .vibe-kanban/workflow-engine.js
class WorkflowEngine {
  constructor() {
    this.agents = new Map();
    this.workflows = new Map();
    this.activeExecutions = new Map();
  }

  registerAgent(name, agent) {
    this.agents.set(name, agent);
  }

  loadWorkflow(workflowConfig) {
    this.workflows.set(workflowConfig.name, workflowConfig);
  }

  async executeWorkflow(workflowName, initialInputs, taskId) {
    const workflow = this.workflows.get(workflowName);
    if (!workflow) {
      throw new Error(`Workflow not found: ${workflowName}`);
    }

    const execution = {
      id: `exec_${Date.now()}`,
      workflow: workflowName,
      taskId: taskId,
      status: 'running',
      steps: new Map(),
      outputs: new Map(),
      startTime: new Date(),
      currentStep: 0
    };

    this.activeExecutions.set(execution.id, execution);

    try {
      const result = await this.runWorkflowSteps(workflow, initialInputs, execution);
      execution.status = 'completed';
      execution.endTime = new Date();
      execution.result = result;
      
      await this.notifyWorkflowCompletion(execution);
      return result;
    } catch (error) {
      execution.status = 'failed';
      execution.error = error.message;
      execution.endTime = new Date();
      
      await this.notifyWorkflowError(execution, error);
      throw error;
    }
  }

  async runWorkflowSteps(workflow, inputs, execution) {
    const stepResults = new Map();
    const stepOutputs = new Map();
    
    // 초기 입력 설정
    stepOutputs.set('initial', inputs);

    for (const step of workflow.steps) {
      execution.currentStep++;
      
      // 의존성 체크
      if (step.depends_on) {
        for (const dependency of step.depends_on) {
          if (!stepResults.has(dependency)) {
            throw new Error(`Dependency not satisfied: ${dependency}`);
          }
        }
      }

      // 입력 준비
      const stepInputs = this.prepareStepInputs(step, stepOutputs);
      
      // 에이전트 실행
      const agent = this.agents.get(step.agent);
      if (!agent) {
        throw new Error(`Agent not found: ${step.agent}`);
      }

      console.log(`Executing step: ${step.task} with agent: ${step.agent}`);
      
      const stepResult = await agent.executeTask({
        id: `${execution.id}_${step.task}`,
        title: step.task,
        description: `Workflow step: ${step.task}`,
        inputs: stepInputs,
        workflow_context: {
          execution_id: execution.id,
          step_number: execution.currentStep,
          workflow_name: workflow.name
        }
      });

      stepResults.set(step.task, stepResult);
      stepOutputs.set(step.task, this.extractStepOutputs(stepResult, step.outputs));
      
      // 진행 상황 업데이트
      await this.updateWorkflowProgress(execution, stepResult);
    }

    return {
      steps: Object.fromEntries(stepResults),
      final_outputs: Object.fromEntries(stepOutputs)
    };
  }

  prepareStepInputs(step, stepOutputs) {
    const inputs = {};
    
    for (const inputName of step.inputs) {
      // 이전 스텝들의 출력에서 입력 찾기
      for (const [stepName, outputs] of stepOutputs) {
        if (outputs[inputName]) {
          inputs[inputName] = outputs[inputName];
          break;
        }
      }
    }

    return inputs;
  }

  async updateWorkflowProgress(execution, stepResult) {
    // Kanban 보드에 진행 상황 업데이트
    await fetch(`http://localhost:3000/api/tasks/${execution.taskId}/progress`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        workflow_progress: {
          execution_id: execution.id,
          current_step: execution.currentStep,
          status: execution.status,
          step_result: stepResult
        }
      })
    });
  }
}

module.exports = WorkflowEngine;
```

## 📊 실제 사용 사례 및 활용법

### 사용 사례 1: 새로운 기능 개발

#### 1. GitHub 이슈 생성부터 완료까지
```bash
#!/bin/bash
# feature-development-example.sh

echo "🚀 Vibe Kanban을 활용한 기능 개발 시나리오"

# 1. GitHub 이슈 생성
gh issue create \
  --title "[FEATURE] 사용자 프로필 이미지 업로드 기능" \
  --body "사용자가 프로필 이미지를 업로드하고 크롭할 수 있는 기능이 필요합니다.

## 요구사항
- 이미지 파일 업로드 (jpg, png, gif)
- 실시간 이미지 크롭 기능
- 썸네일 자동 생성
- 파일 크기 최적화

## 기술 스택
- React.js (프론트엔드)
- Node.js + Express (백엔드)
- Sharp.js (이미지 처리)
- AWS S3 (파일 저장)

## 추정 작업 시간
3-5일" \
  --label "enhancement,priority: high" \
  --assignee $(gh api user --jq .login)

echo "✅ GitHub 이슈 생성 완료"

# 2. Vibe Kanban에서 자동으로 태스크 생성됨 (웹훅을 통해)
echo "⏳ Vibe Kanban 보드에 태스크 자동 생성 중..."
sleep 2

# 3. Claude Code가 요구사항 분석 시작
echo "🤖 Claude Code: 요구사항 분석 시작"
curl -X POST http://localhost:3000/api/tasks/github-issue-123/execute \
  -H "Content-Type: application/json" \
  -d '{
    "agent": "claude_code",
    "action": "analyze_requirements",
    "context": {
      "github_issue": 123,
      "priority": "high"
    }
  }'

# 4. Gemini CLI가 UI/UX 디자인 분석
echo "🎨 Gemini CLI: UI/UX 디자인 분석"
curl -X POST http://localhost:3000/api/tasks/github-issue-123/execute \
  -H "Content-Type: application/json" \
  -d '{
    "agent": "gemini_cli",
    "action": "design_analysis",
    "context": {
      "feature_type": "image_upload",
      "ui_patterns": ["crop", "drag_drop", "preview"]
    }
  }'

echo "🎯 기능 개발 워크플로우가 시작되었습니다!"
echo "📊 진행 상황은 http://localhost:3000에서 확인하세요."
```

#### 2. 실시간 진행 상황 모니터링
```javascript
// monitoring-dashboard.js
class KanbanMonitoring {
  constructor() {
    this.ws = new WebSocket('ws://localhost:3000/ws');
    this.setupEventListeners();
  }

  setupEventListeners() {
    this.ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      this.handleRealtimeUpdate(data);
    };
  }

  handleRealtimeUpdate(data) {
    switch (data.type) {
      case 'task_moved':
        this.updateTaskPosition(data.task);
        break;
      case 'agent_started':
        this.showAgentActivity(data.agent, data.task);
        break;
      case 'agent_completed':
        this.showAgentResults(data.agent, data.results);
        break;
      case 'workflow_progress':
        this.updateWorkflowProgress(data.workflow, data.progress);
        break;
    }
  }

  updateTaskPosition(task) {
    const taskElement = document.getElementById(`task-${task.id}`);
    const newBoard = document.getElementById(`board-${task.board}`);
    
    // 시각적 효과와 함께 태스크 이동
    taskElement.style.transform = 'scale(1.05)';
    taskElement.style.transition = 'all 0.3s ease';
    
    setTimeout(() => {
      newBoard.appendChild(taskElement);
      taskElement.style.transform = 'scale(1)';
    }, 150);
  }

  showAgentActivity(agent, task) {
    const notification = document.createElement('div');
    notification.className = 'agent-notification';
    notification.innerHTML = `
      <div class="agent-avatar">
        <img src="/agents/${agent.name}/avatar.png" alt="${agent.name}">
      </div>
      <div class="agent-message">
        <strong>${agent.name}</strong>이 작업을 시작했습니다: 
        <em>${task.title}</em>
      </div>
    `;
    
    document.getElementById('notifications').appendChild(notification);
    
    // 3초 후 자동 제거
    setTimeout(() => notification.remove(), 3000);
  }
}

// 모니터링 시작
const monitoring = new KanbanMonitoring();
```

### 사용 사례 2: 버그 수정 워크플로우

#### 1. 버그 리포트부터 수정까지
```python
# bug-fix-automation.py
import requests
import json
from datetime import datetime

class BugFixAutomation:
    def __init__(self):
        self.kanban_api = "http://localhost:3000/api"
        self.github_api = "https://api.github.com"
        
    def handle_bug_report(self, issue_data):
        """버그 리포트 처리"""
        bug_task = {
            "id": f"bug-{issue_data['number']}",
            "title": f"🐛 {issue_data['title']}",
            "description": issue_data['body'],
            "type": "Bug Fix",
            "priority": self.detect_severity(issue_data['body']),
            "github_issue": issue_data['number'],
            "board": "Backlog",
            "created_at": datetime.now().isoformat(),
            "labels": [label['name'] for label in issue_data['labels']]
        }
        
        # Kanban 보드에 태스크 생성
        response = requests.post(
            f"{self.kanban_api}/tasks",
            json=bug_task
        )
        
        if response.status_code == 201:
            # Gemini CLI로 버그 분석 시작
            self.start_bug_analysis(bug_task['id'])
            
        return response.json()
    
    def detect_severity(self, description):
        """버그 설명에서 심각도 추출"""
        critical_keywords = ['crash', 'data loss', 'security', 'critical']
        high_keywords = ['error', 'exception', 'fails', 'broken']
        
        description_lower = description.lower()
        
        if any(keyword in description_lower for keyword in critical_keywords):
            return "Critical"
        elif any(keyword in description_lower for keyword in high_keywords):
            return "High"
        else:
            return "Medium"
    
    def start_bug_analysis(self, task_id):
        """Gemini CLI로 버그 분석 시작"""
        analysis_request = {
            "agent": "gemini_cli",
            "action": "analyze_bug_report",
            "context": {
                "include_logs": True,
                "include_screenshots": True,
                "analyze_patterns": True
            }
        }
        
        response = requests.post(
            f"{self.kanban_api}/tasks/{task_id}/execute",
            json=analysis_request
        )
        
        if response.status_code == 200:
            print(f"✅ 버그 분석 시작: {task_id}")
            # 분석 완료 후 Claude Code로 수정 작업 전달
            self.schedule_bug_fix(task_id)
    
    def schedule_bug_fix(self, task_id):
        """Claude Code로 버그 수정 스케줄링"""
        fix_request = {
            "agent": "claude_code",
            "action": "implement_bug_fix",
            "context": {
                "run_tests": True,
                "create_regression_tests": True,
                "update_documentation": True
            },
            "depends_on": ["analyze_bug_report"]
        }
        
        response = requests.post(
            f"{self.kanban_api}/tasks/{task_id}/schedule",
            json=fix_request
        )
        
        return response.json()

# 사용 예제
automation = BugFixAutomation()

# 웹훅에서 받은 GitHub 이슈 데이터
github_issue = {
    "number": 456,
    "title": "사용자 로그인 시 세션 만료 오류",
    "body": """
## 버그 설명
사용자가 로그인한 후 5분 이내에 세션이 임의로 만료되는 문제가 발생합니다.

## 재현 단계
1. 사용자 로그인
2. 대시보드 페이지 이동
3. 5분 대기
4. 아무 버튼이나 클릭

## 예상 결과
세션이 유지되어야 함

## 실제 결과
"세션이 만료되었습니다" 오류 메시지 표시

## 환경
- Browser: Chrome 120.0
- OS: Windows 11
- Version: v2.1.3
    """,
    "labels": [
        {"name": "bug"},
        {"name": "priority: high"},
        {"name": "authentication"}
    ]
}

result = automation.handle_bug_report(github_issue)
print(f"버그 처리 결과: {result}")
```

### 사용 사례 3: 연구 및 문서화 프로젝트

#### 1. AI 에이전트 기반 리서치 워크플로우
```yaml
# research-workflow-example.yaml
name: "AI Research Project"
description: "AI 에이전트들을 활용한 기술 리서치 및 문서화"

research_pipeline:
  - stage: "Topic Analysis"
    agent: "gemini_cli"
    tasks:
      - "시장 동향 분석"
      - "경쟁사 기술 조사"
      - "사용자 니즈 파악"
    outputs:
      - "market_analysis.md"
      - "competitor_report.md"
      - "user_requirements.md"
      
  - stage: "Technical Deep Dive"
    agent: "claude_code"
    tasks:
      - "기술 스택 분석"
      - "아키텍처 설계"
      - "구현 가능성 검토"
    inputs:
      - "market_analysis.md"
      - "user_requirements.md"
    outputs:
      - "tech_stack_analysis.md"
      - "architecture_design.md"
      - "feasibility_report.md"
      
  - stage: "Prototype Development"
    agent: "claude_code"
    tasks:
      - "프로토타입 코드 작성"
      - "데모 애플리케이션 개발"
      - "성능 테스트"
    inputs:
      - "architecture_design.md"
      - "tech_stack_analysis.md"
    outputs:
      - "prototype/"
      - "demo_app/"
      - "performance_results.md"
      
  - stage: "Documentation & Presentation"
    agent: "gemini_cli"
    tasks:
      - "종합 보고서 작성"
      - "프레젠테이션 자료 생성"
      - "시각적 자료 제작"
    inputs:
      - "feasibility_report.md"
      - "performance_results.md"
    outputs:
      - "final_report.md"
      - "presentation.pptx"
      - "infographics/"

automation_rules:
  - trigger: "stage_completed"
    condition: "all_tasks_done"
    action: "move_to_next_stage"
    
  - trigger: "task_failed"
    condition: "error_count > 2"
    action: "escalate_to_human"
    
  - trigger: "research_completed"
    condition: "final_stage_done"
    action: "create_github_release"
```

#### 2. 자동화된 문서 생성
```python
# documentation-generator.py
class DocumentationGenerator:
    def __init__(self):
        self.claude = ClaudeCodeAgent()
        self.gemini = GeminiCLIAgent()
        
    async def generate_project_docs(self, project_path):
        """프로젝트 전체 문서 자동 생성"""
        
        # 1. 코드 분석
        code_analysis = await self.claude.executeTask({
            "title": "코드베이스 분석",
            "description": f"프로젝트 {project_path}의 전체 구조와 기능을 분석하세요",
            "context": {
                "project_path": project_path,
                "include_dependencies": True,
                "analyze_patterns": True
            }
        })
        
        # 2. API 문서 생성
        api_docs = await self.claude.executeTask({
            "title": "API 문서 생성",
            "description": "REST API 엔드포인트 문서를 자동 생성하세요",
            "context": {
                "code_analysis": code_analysis,
                "format": "openapi_3.0",
                "include_examples": True
            }
        })
        
        # 3. 사용자 가이드 생성
        user_guide = await self.gemini.executeTask({
            "title": "사용자 가이드 생성",
            "description": "초보자도 이해할 수 있는 사용자 가이드를 작성하세요",
            "context": {
                "api_docs": api_docs,
                "target_audience": "developers",
                "include_tutorials": True,
                "include_screenshots": True
            }
        })
        
        # 4. 배포 가이드 생성
        deployment_guide = await self.claude.executeTask({
            "title": "배포 가이드 생성",
            "description": "다양한 환경에서의 배포 방법을 문서화하세요",
            "context": {
                "deployment_targets": ["docker", "kubernetes", "aws", "vercel"],
                "include_troubleshooting": True
            }
        })
        
        # 5. 문서 통합 및 정리
        final_docs = await self.gemini.executeTask({
            "title": "문서 통합",
            "description": "모든 문서를 통합하고 일관성 있게 정리하세요",
            "context": {
                "documents": [api_docs, user_guide, deployment_guide],
                "format": "gitbook",
                "create_index": True,
                "add_navigation": True
            }
        })
        
        return final_docs

# 사용 예제
async def main():
    generator = DocumentationGenerator()
    docs = await generator.generate_project_docs("./my-awesome-project")
    
    # GitHub에 문서 커밋
    subprocess.run([
        "git", "add", "docs/",
        "git", "commit", "-m", "📚 Auto-generated documentation",
        "git", "push"
    ])
    
    print("✅ 프로젝트 문서 자동 생성 완료!")

# 실행
import asyncio
asyncio.run(main())
```

## 🎯 고급 기능 및 통합

### Slack 통합

#### 1. Slack 봇 설정
```javascript
// .vibe-kanban/integrations/slack-bot.js
const { App } = require('@slack/bolt');

class SlackKanbanBot {
  constructor(config) {
    this.app = new App({
      token: process.env.SLACK_BOT_TOKEN,
      signingSecret: process.env.SLACK_SIGNING_SECRET,
      socketMode: true,
      appToken: process.env.SLACK_APP_TOKEN
    });
    
    this.setupCommands();
    this.setupEvents();
  }

  setupCommands() {
    // /kanban status 명령어
    this.app.command('/kanban-status', async ({ ack, body, client }) => {
      await ack();
      
      const status = await this.getKanbanStatus();
      
      await client.chat.postMessage({
        channel: body.channel_id,
        blocks: [
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: "🎯 *Kanban Board Status*"
            }
          },
          {
            type: "section",
            fields: [
              {
                type: "mrkdwn",
                text: `*Backlog:* ${status.backlog} tasks`
              },
              {
                type: "mrkdwn",
                text: `*In Progress:* ${status.in_progress} tasks`
              },
              {
                type: "mrkdwn",
                text: `*Review:* ${status.review} tasks`
              },
              {
                type: "mrkdwn",
                text: `*Done:* ${status.done} tasks`
              }
            ]
          },
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: `🤖 *Active AI Agents:* ${status.active_agents.join(', ')}`
            }
          },
          {
            type: "actions",
            elements: [
              {
                type: "button",
                text: {
                  type: "plain_text",
                  text: "View Board"
                },
                url: "http://localhost:3000",
                action_id: "view_board"
              }
            ]
          }
        ]
      });
    });

    // /kanban create 명령어
    this.app.command('/kanban-create', async ({ ack, body, client }) => {
      await ack();
      
      // 모달 열기
      await client.views.open({
        trigger_id: body.trigger_id,
        view: {
          type: "modal",
          callback_id: "create_task_modal",
          title: {
            type: "plain_text",
            text: "Create New Task"
          },
          submit: {
            type: "plain_text",
            text: "Create"
          },
          blocks: [
            {
              type: "input",
              block_id: "task_title",
              element: {
                type: "plain_text_input",
                action_id: "title",
                placeholder: {
                  type: "plain_text",
                  text: "Enter task title"
                }
              },
              label: {
                type: "plain_text",
                text: "Title"
              }
            },
            {
              type: "input",
              block_id: "task_description",
              element: {
                type: "plain_text_input",
                action_id: "description",
                multiline: true,
                placeholder: {
                  type: "plain_text",
                  text: "Enter task description"
                }
              },
              label: {
                type: "plain_text",
                text: "Description"
              }
            },
            {
              type: "input",
              block_id: "task_type",
              element: {
                type: "static_select",
                action_id: "type",
                options: [
                  {
                    text: {
                      type: "plain_text",
                      text: "Feature"
                    },
                    value: "feature"
                  },
                  {
                    text: {
                      type: "plain_text",
                      text: "Bug Fix"
                    },
                    value: "bug_fix"
                  },
                  {
                    text: {
                      type: "plain_text",
                      text: "Documentation"
                    },
                    value: "documentation"
                  }
                ]
              },
              label: {
                type: "plain_text",
                text: "Task Type"
              }
            }
          ]
        }
      });
    });
  }

  setupEvents() {
    // 태스크 생성 모달 제출
    this.app.view('create_task_modal', async ({ ack, body, view, client }) => {
      await ack();
      
      const values = view.state.values;
      const task = {
        title: values.task_title.title.value,
        description: values.task_description.description.value,
        type: values.task_type.type.selected_option.value,
        created_by: body.user.id,
        board: 'Backlog'
      };
      
      // Kanban API로 태스크 생성
      const response = await fetch('http://localhost:3000/api/tasks', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(task)
      });
      
      if (response.ok) {
        const createdTask = await response.json();
        
        // 채널에 알림 전송
        await client.chat.postMessage({
          channel: body.user.id,
          text: `✅ Task created: *${task.title}*\nView it at: http://localhost:3000/tasks/${createdTask.id}`
        });
      }
    });
  }

  async getKanbanStatus() {
    const response = await fetch('http://localhost:3000/api/status');
    return response.json();
  }

  async start() {
    await this.app.start();
    console.log('⚡️ Slack Kanban Bot is running!');
  }
}

module.exports = SlackKanbanBot;
```

### 메트릭 및 분석

#### 1. 대시보드 설정
```python
# analytics-dashboard.py
import streamlit as st
import pandas as pd
import plotly.express as px
import requests
from datetime import datetime, timedelta

class KanbanAnalytics:
    def __init__(self):
        self.api_base = "http://localhost:3000/api"
        
    def get_task_data(self, days=30):
        """최근 N일간의 태스크 데이터 가져오기"""
        end_date = datetime.now()
        start_date = end_date - timedelta(days=days)
        
        response = requests.get(
            f"{self.api_base}/tasks",
            params={
                "start_date": start_date.isoformat(),
                "end_date": end_date.isoformat()
            }
        )
        
        return pd.DataFrame(response.json())
    
    def get_agent_performance(self, days=30):
        """AI 에이전트 성능 데이터"""
        response = requests.get(
            f"{self.api_base}/agents/performance",
            params={"days": days}
        )
        
        return pd.DataFrame(response.json())
    
    def render_dashboard(self):
        st.set_page_config(
            page_title="Vibe Kanban Analytics",
            page_icon="📊",
            layout="wide"
        )
        
        st.title("📊 Vibe Kanban Analytics Dashboard")
        
        # 사이드바 필터
        st.sidebar.header("Filters")
        days = st.sidebar.slider("Days to analyze", 7, 90, 30)
        
        # 데이터 로드
        task_data = self.get_task_data(days)
        agent_data = self.get_agent_performance(days)
        
        if task_data.empty:
            st.warning("No data available for the selected period")
            return
        
        # 메트릭 요약
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            total_tasks = len(task_data)
            st.metric("Total Tasks", total_tasks)
        
        with col2:
            completed_tasks = len(task_data[task_data['status'] == 'Done'])
            completion_rate = (completed_tasks / total_tasks * 100) if total_tasks > 0 else 0
            st.metric("Completion Rate", f"{completion_rate:.1f}%")
        
        with col3:
            avg_time = task_data['completion_time_hours'].mean()
            st.metric("Avg Completion Time", f"{avg_time:.1f}h")
        
        with col4:
            active_agents = agent_data['agent_name'].nunique()
            st.metric("Active AI Agents", active_agents)
        
        # 차트들
        col1, col2 = st.columns(2)
        
        with col1:
            # 태스크 타입별 분포
            fig_type = px.pie(
                task_data.groupby('type').size().reset_index(name='count'),
                values='count',
                names='type',
                title="Tasks by Type"
            )
            st.plotly_chart(fig_type, use_container_width=True)
        
        with col2:
            # 완료 시간 트렌드
            daily_completion = task_data.groupby(
                task_data['completed_date'].dt.date
            ).size().reset_index(name='completed_tasks')
            
            fig_trend = px.line(
                daily_completion,
                x='completed_date',
                y='completed_tasks',
                title="Daily Task Completion Trend"
            )
            st.plotly_chart(fig_trend, use_container_width=True)
        
        # AI 에이전트 성능
        st.subheader("🤖 AI Agent Performance")
        
        agent_metrics = agent_data.groupby('agent_name').agg({
            'tasks_completed': 'sum',
            'avg_execution_time': 'mean',
            'success_rate': 'mean'
        }).round(2)
        
        st.dataframe(agent_metrics, use_container_width=True)
        
        # 에이전트별 작업 시간 분포
        fig_agent = px.box(
            agent_data,
            x='agent_name',
            y='execution_time_seconds',
            title="Agent Execution Time Distribution"
        )
        st.plotly_chart(fig_agent, use_container_width=True)
        
        # 상세 태스크 목록
        st.subheader("📋 Recent Tasks")
        
        # 필터 옵션
        status_filter = st.selectbox(
            "Filter by status",
            options=['All'] + list(task_data['status'].unique())
        )
        
        filtered_data = task_data
        if status_filter != 'All':
            filtered_data = task_data[task_data['status'] == status_filter]
        
        st.dataframe(
            filtered_data[['title', 'type', 'status', 'assignee', 'created_date', 'completion_time_hours']],
            use_container_width=True
        )

# Streamlit 앱 실행
if __name__ == "__main__":
    analytics = KanbanAnalytics()
    analytics.render_dashboard()
```

#### 2. 성능 모니터링 스크립트
```bash
#!/bin/bash
# performance-monitoring.sh

echo "📊 Vibe Kanban 성능 모니터링 시작..."

# 시스템 리소스 확인
echo "=== 시스템 리소스 ==="
echo "CPU 사용률: $(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')"
echo "메모리 사용률: $(vm_stat | grep "Pages active" | awk '{print $3}' | sed 's/\.//')"
echo "디스크 사용률: $(df -h . | tail -1 | awk '{print $5}')"

# Vibe Kanban API 상태 확인
echo -e "\n=== API 상태 ==="
API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health)
if [ "$API_STATUS" = "200" ]; then
    echo "✅ API 서버 정상"
else
    echo "❌ API 서버 오류 (HTTP $API_STATUS)"
fi

# 활성 AI 에이전트 확인
echo -e "\n=== AI 에이전트 상태 ==="
AGENTS_STATUS=$(curl -s http://localhost:3000/api/agents/status)
echo "$AGENTS_STATUS" | jq -r '.agents[] | "\(.name): \(.status) (Tasks: \(.active_tasks))"'

# 최근 에러 로그 확인
echo -e "\n=== 최근 에러 로그 ==="
if [ -f ".vibe-kanban/logs/error.log" ]; then
    tail -5 .vibe-kanban/logs/error.log
else
    echo "에러 로그 없음"
fi

# 성능 메트릭 수집
echo -e "\n=== 성능 메트릭 ==="
METRICS=$(curl -s http://localhost:3000/api/metrics)
echo "$METRICS" | jq -r '
"평균 응답시간: \(.avg_response_time_ms)ms",
"처리된 태스크: \(.tasks_processed_today)",
"성공률: \(.success_rate)%",
"활성 연결: \(.active_connections)"
'

# 자동화된 알림 (선택사항)
if [ "$API_STATUS" != "200" ]; then
    # Slack 알림 전송
    curl -X POST -H 'Content-type: application/json' \
        --data '{"text":"🚨 Vibe Kanban API 서버 다운!"}' \
        "$SLACK_WEBHOOK_URL"
fi

echo -e "\n✅ 모니터링 완료"
```

## zshrc 별칭 설정

```bash
# ~/.zshrc에 추가할 Vibe Kanban 관련 별칭들

# Vibe Kanban 관련 디렉토리
export VIBE_KANBAN_HOME="$HOME/.vibe-kanban"
export VIBE_PROJECTS_DIR="$HOME/vibe-projects"

# 기본 별칭
alias vkanban="npx vibe-kanban"
alias vk="npx vibe-kanban"
alias vk-init="npx vibe-kanban init"
alias vk-start="npm run kanban"
alias vk-dev="npm run kanban:dev"

# 프로젝트 관리
alias vk-new="mkdir -p $VIBE_PROJECTS_DIR && cd $VIBE_PROJECTS_DIR"
alias vk-list="ls -la $VIBE_PROJECTS_DIR"
alias vk-goto="cd $VIBE_PROJECTS_DIR"

# 설정 관리
alias vk-config="code $VIBE_KANBAN_HOME/config.json"
alias vk-agents="code $VIBE_KANBAN_HOME/agents/"
alias vk-workflows="code $VIBE_KANBAN_HOME/workflows/"

# API 및 상태 확인
alias vk-status="curl -s http://localhost:3000/api/health | jq ."
alias vk-agents-status="curl -s http://localhost:3000/api/agents/status | jq ."
alias vk-metrics="curl -s http://localhost:3000/api/metrics | jq ."

# 로그 확인
alias vk-logs="tail -f $VIBE_KANBAN_HOME/logs/app.log"
alias vk-errors="tail -f $VIBE_KANBAN_HOME/logs/error.log"

# GitHub 통합
alias vk-gh-setup="gh auth login && gh api user"
alias vk-webhook="ngrok http 3000" # 로컬 웹훅 테스트용

# 개발 도구
alias vk-test="npm run test"
alias vk-lint="npm run lint"
alias vk-build="npm run build"

# 백업 및 복원
function vk-backup() {
    local backup_name="vibe-kanban-backup-$(date +%Y%m%d-%H%M%S)"
    tar -czf "$backup_name.tar.gz" "$VIBE_KANBAN_HOME" 
    echo "✅ 백업 완료: $backup_name.tar.gz"
}

function vk-restore() {
    if [ -z "$1" ]; then
        echo "사용법: vk-restore <backup-file.tar.gz>"
        return 1
    fi
    tar -xzf "$1" -C "$HOME"
    echo "✅ 복원 완료: $1"
}

# 빠른 태스크 생성
function vk-task() {
    if [ -z "$1" ]; then
        echo "사용법: vk-task 'Task Title' ['Description']"
        return 1
    fi
    
    local title="$1"
    local description="${2:-Auto-created task}"
    
    curl -X POST http://localhost:3000/api/tasks \
        -H "Content-Type: application/json" \
        -d "{
            \"title\": \"$title\",
            \"description\": \"$description\",
            \"type\": \"Feature\",
            \"board\": \"Backlog\"
        }" | jq .
}

# 프로젝트 초기화
function vk-init-project() {
    local project_name="$1"
    if [ -z "$project_name" ]; then
        echo "사용법: vk-init-project <project-name>"
        return 1
    fi
    
    mkdir -p "$VIBE_PROJECTS_DIR/$project_name"
    cd "$VIBE_PROJECTS_DIR/$project_name"
    
    npm init -y
    npm install --save-dev vibe-kanban
    npx vibe-kanban init
    
    echo "✅ 프로젝트 '$project_name' 초기화 완료"
    echo "📁 경로: $VIBE_PROJECTS_DIR/$project_name"
}

# 에이전트 테스트
function vk-test-agent() {
    local agent_name="$1"
    if [ -z "$agent_name" ]; then
        echo "사용 가능한 에이전트: claude_code, gemini_cli, cursor"
        return 1
    fi
    
    curl -X POST "http://localhost:3000/api/agents/$agent_name/test" \
        -H "Content-Type: application/json" \
        -d '{"test_task": "Hello, World!"}' | jq .
}

# 성능 모니터링
function vk-monitor() {
    echo "📊 Vibe Kanban 실시간 모니터링..."
    while true; do
        clear
        echo "=== $(date) ==="
        vk-status
        echo ""
        vk-agents-status
        echo ""
        echo "다음 업데이트까지 5초..."
        sleep 5
    done
}

# 도움말
function vk-help() {
    echo "🚀 Vibe Kanban 별칭 도움말"
    echo ""
    echo "기본 사용:"
    echo "  vkanban        - Vibe Kanban 실행"
    echo "  vk-init        - 새 프로젝트 초기화"
    echo "  vk-start       - 개발 서버 시작"
    echo ""
    echo "프로젝트 관리:"
    echo "  vk-init-project <name>  - 새 프로젝트 생성"
    echo "  vk-list        - 프로젝트 목록"
    echo "  vk-goto        - 프로젝트 디렉토리로 이동"
    echo ""
    echo "상태 확인:"
    echo "  vk-status      - API 서버 상태"
    echo "  vk-agents-status - AI 에이전트 상태"
    echo "  vk-monitor     - 실시간 모니터링"
    echo ""
    echo "개발 도구:"
    echo "  vk-task 'title' - 빠른 태스크 생성"
    echo "  vk-test-agent <name> - 에이전트 테스트"
    echo "  vk-backup      - 설정 백업"
    echo ""
    echo "설정:"
    echo "  vk-config      - 설정 파일 편집"
    echo "  vk-agents      - 에이전트 설정 편집"
    echo "  vk-workflows   - 워크플로우 편집"
}
```

## 개발환경 정보

```bash
# 테스트 환경 정보
echo "=== Vibe Kanban 개발환경 정보 ==="
echo "날짜: $(date)"
echo "OS: $(uname -a)"
echo "Node.js: $(node --version 2>/dev/null || echo 'Node.js not installed')"
echo "npm: $(npm --version 2>/dev/null || echo 'npm not installed')"
echo "Git: $(git --version 2>/dev/null || echo 'Git not installed')"
echo "GitHub CLI: $(gh --version 2>/dev/null | head -1 || echo 'GitHub CLI not installed')"
echo "Python: $(python --version 2>&1 || echo 'Python not installed')"
echo "사용 가능 메모리: $(free -h 2>/dev/null | grep Mem || vm_stat | head -5)"
echo "디스크 공간: $(df -h . | tail -1)"
```

### 검증된 환경

이 가이드는 다음 환경에서 테스트되었습니다:

```
- macOS Sonoma (Apple M4 Pro, 48GB RAM)
- Ubuntu 22.04 LTS
- Node.js 20.0+ (LTS)
- npm 10.0+
- GitHub CLI 2.40+
- Python 3.10+
```

## 결론

Vibe Kanban은 Apache-2.0 라이선스 하에서 **완전히 자유로운 상업적 사용이 가능**한 혁신적인 AI 에이전트 관리 도구입니다. 기존 GitHub 프로젝트와의 완벽한 통합을 통해 다음과 같은 강력한 기능들을 제공합니다:

### 🎯 주요 장점

1. **AI 에이전트 통합 관리**: Claude Code, Gemini CLI 등 다양한 AI 도구들을 하나의 플랫폼에서 관리
2. **시각적 워크플로우**: 칸반 보드를 통한 직관적인 작업 흐름 관리
3. **GitHub 완벽 연동**: 이슈, PR, 커밋과 자동 동기화
4. **자동화된 워크플로우**: AI 에이전트 간 협업을 통한 자동화된 개발 프로세스
5. **확장 가능한 아키텍처**: 플러그인과 통합을 통한 무한한 확장성

### 🚀 권장 도입 전략

1. **개인 프로젝트부터 시작**: 소규모 프로젝트에서 워크플로우 검증
2. **팀 단위 확장**: 성공적인 개인 사용 후 팀 차원으로 확대
3. **기업 전사 도입**: 검증된 워크플로우를 전사 표준으로 확산
4. **커스터마이징**: 조직의 특성에 맞는 에이전트와 워크플로우 개발

### 💡 활용 시나리오

- **개발팀**: 코드 리뷰, 버그 수정, 기능 개발 자동화
- **연구팀**: 문서 생성, 데이터 분석, 리포트 작성 자동화
- **스타트업**: 제한된 인력으로 최대 효율성 달성
- **대기업**: 복잡한 프로젝트의 체계적 관리

Vibe Kanban을 통해 AI 에이전트들이 단순한 도구가 아닌 **진정한 팀 멤버**로 기능할 수 있으며, 인간 개발자들은 더욱 창의적이고 전략적인 업무에 집중할 수 있게 됩니다.

### 관련 링크

- [Vibe Kanban GitHub](https://github.com/BloopAI/vibe-kanban)
- [Apache-2.0 라이선스](https://www.apache.org/licenses/LICENSE-2.0)
- [Claude Code 가이드](https://docs.anthropic.com/claude/docs)
- [Gemini CLI 문서](https://cloud.google.com/vertex-ai/docs/generative-ai/model-reference/gemini)
- [GitHub API 문서](https://docs.github.com/en/rest) 