---
title: "CUI: Claude Code 에이전트를 위한 모던 웹 UI 완전 가이드"
excerpt: "CLI에서 웹으로! Claude Code의 모든 기능을 브라우저에서 사용할 수 있는 CUI 웹 인터페이스의 설치부터 고급 기능까지 완벽 가이드"
seo_title: "CUI Claude Code Web UI 완전 설정 가이드 - Thaki Cloud"
seo_description: "Claude Code를 웹 브라우저에서 사용할 수 있는 CUI 설정 방법. 병렬 에이전트, 태스크 관리, 음성 인식, 푸시 알림까지 모든 기능 활용법"
date: 2025-08-05
last_modified_at: 2025-08-05
categories:
  - tutorials
tags:
  - cui
  - claude-code
  - web-ui
  - ai-agent
  - typescript
  - react
  - claude
  - anthropic
  - nodejs
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/cui-claude-code-web-ui-complete-guide/"
reading_time: true
published: false
---

⏱️ **예상 읽기 시간**: 15분

## 서론

**Claude Code**는 Anthropic의 강력한 AI 코딩 어시스턴트이지만, CLI 환경에서만 사용할 수 있다는 제약이 있었습니다. 이런 불편함을 해결하기 위해 등장한 [CUI (Claude Code Web UI)](https://github.com/wbopan/cui)는 Claude Code의 모든 기능을 **모던하고 직관적인 웹 인터페이스**로 제공합니다.

CUI를 사용하면 브라우저 어디서나 Claude Code에 접근할 수 있으며, **병렬 백그라운드 에이전트**, **태스크 관리**, **실시간 알림**, **음성 인식** 등의 고급 기능까지 활용할 수 있습니다. 이번 가이드에서는 CUI의 설치부터 활용까지 모든 과정을 상세히 다루겠습니다.

## CUI 핵심 기능

### 🎨 모던 디자인 & 반응형 UI

CUI는 **React와 TypeScript** 기반으로 구축된 최신 웹 애플리케이션입니다.

#### 주요 UI 특징
- **반응형 디자인**: 데스크톱, 태블릿, 모바일 모든 기기 지원
- **다크/라이트 테마**: 사용자 선호도에 맞는 테마 선택
- **실시간 스트리밍**: Claude의 응답을 실시간으로 확인
- **직관적 네비게이션**: 태스크와 히스토리 간편 관리

### 🔄 병렬 백그라운드 에이전트

가장 강력한 기능 중 하나는 **여러 Claude 세션을 동시에 실행**할 수 있다는 점입니다.

```typescript
// 동시 실행 가능한 작업들
const tasks = [
  { name: "웹사이트 리팩토링", directory: "/project/frontend" },
  { name: "API 개발", directory: "/project/backend" },
  { name: "문서 작성", directory: "/project/docs" }
];

// 각 태스크는 독립적으로 백그라운드에서 실행
tasks.forEach(task => {
  cui.startTask(task.name, task.directory);
});
```

### 📋 태스크 관리 시스템

CUI는 Claude Code 히스토리를 자동으로 스캔하고 체계적으로 관리합니다.

#### 태스크 라이프사이클
1. **시작**: 새로운 태스크 생성 또는 기존 태스크 재개
2. **실행**: 백그라운드에서 지속 실행
3. **포크**: 기존 태스크에서 새로운 브랜치 생성
4. **아카이브**: 완료된 태스크 정리

### 🔔 푸시 알림 & 🎤 음성 인식

#### 푸시 알림 (ntfy 기반)
```bash
# ntfy 설치 (macOS)
brew install ntfy

# ntfy 설치 (Linux)
sudo apt install ntfy

# 알림 구독
ntfy subscribe your-topic-name
```

#### 음성 인식 (Gemini 2.5 Flash)
```bash
# Gemini API 키 설정
export GOOGLE_API_KEY="your-gemini-api-key"

# CUI 서버 시작
npx cui-server
```

## 설치 및 기본 설정

### 1. 시스템 요구사항

```bash
# Node.js 버전 확인
node --version  # >= 20.19.0 필요

# npm 버전 확인  
npm --version

# Claude Code 설치 확인
claude --version
```

#### 필수 요구사항
- **Node.js**: 20.19.0 이상
- **Claude Code**: 최신 버전 설치 및 로그인 완료
- **Anthropic API Key**: 선택사항 (Claude Code 로그인 시 불필요)

### 2. CUI 설치

#### 방법 1: npx 사용 (권장)
```bash
# 별도 설치 없이 바로 실행
npx cui-server

# 커스텀 포트로 실행
npx cui-server --port 3002 --host 0.0.0.0
```

#### 방법 2: 글로벌 설치
```bash
# 글로벌 설치
npm install -g cui-server

# 실행
cui-server

# 버전 확인
cui-server --version
```

### 3. 초기 접속

```bash
# 서버 시작 후 터미널에 표시되는 내용
CUI Server starting...
🚀 Server running at http://localhost:3001
🔑 Access token: abc123xyz789
🌐 Open: http://localhost:3001/#abc123xyz789
```

브라우저에서 표시된 URL로 접속하면 바로 사용할 수 있습니다.

## 기본 사용법

### 1. 새로운 태스크 시작

#### 홈페이지에서 시작
```markdown
1. CUI 웹 인터페이스 접속
2. 메인 입력창에 작업 내용 입력
3. 드롭다운에서 작업 디렉토리 선택
4. Enter 또는 Send 버튼으로 전송
```

#### CLI 명령어 지원
```bash
# 프로젝트 초기화
/init

# 파일 참조
@src/components/Header.tsx

# 도움말
/help

# 디렉토리 변경
/cd /path/to/project
```

### 2. 태스크 관리

#### 실행 중인 태스크 확인
```typescript
// Tasks 탭에서 확인 가능한 정보
interface TaskInfo {
  id: string;
  name: string;
  status: 'running' | 'waiting' | 'completed' | 'error';
  directory: string;
  startTime: Date;
  lastActivity: Date;
  messages: number;
}
```

#### 태스크 포크 생성
```markdown
1. History 탭으로 이동
2. 포크하고 싶은 세션 선택
3. "Fork" 버튼 클릭
4. 새로운 메시지로 브랜치 생성
```

### 3. 키보드 단축키

| 단축키 | 기능 |
|--------|------|
| `Enter` | 새 줄 추가 |
| `Ctrl/Cmd + Enter` | 메시지 전송 |
| `/` | 명령어 목록 표시 |
| `@` | 현재 디렉토리 파일 목록 |
| `Esc` | 입력창 포커스 해제 |

## 고급 기능 활용

### 1. 원격 접속 설정

#### 설정 파일 수정
```json
// ~/.cui/config.json
{
  "server": {
    "host": "0.0.0.0",
    "port": 3001,
    "authToken": "your-secure-token-here"
  },
  "notifications": {
    "enabled": true,
    "ntfyTopic": "cui-notifications-unique-id"
  },
  "dictation": {
    "enabled": true,
    "googleApiKey": "your-google-api-key"
  }
}
```

#### 보안 고려사항
```bash
# 강력한 인증 토큰 생성
openssl rand -hex 32

# HTTPS 프록시 설정 (Caddy 예제)
# Caddyfile
your-domain.com {
    reverse_proxy localhost:3001
    basicauth /* {
        your-username your-hashed-password
    }
}
```

### 2. 알림 시스템 구성

#### ntfy 클라이언트 설정
```bash
# 모바일 앱 설치
# iOS: App Store에서 "ntfy" 검색
# Android: Play Store에서 "ntfy" 검색

# 토픽 구독
# 앱에서 고유한 토픽명 입력
# 예: cui-notifications-john-dev-2024
```

#### 알림 테스트
```bash
# 수동 알림 테스트
curl -d "Hello from CUI!" ntfy.sh/your-topic-name

# CUI에서 자동 알림 발생 상황:
# 1. 태스크 완료 시
# 2. Claude가 도구 사용 권한 요청 시
# 3. 오류 발생 시
```

### 3. 음성 인식 설정

#### Gemini API 키 발급
```markdown
1. Google AI Studio 접속 (https://aistudio.google.com)
2. API 키 생성
3. 환경변수 설정 또는 config.json에 추가
```

#### 환경변수 설정
```bash
# 영구 설정 (macOS/Linux)
echo 'export GOOGLE_API_KEY="your-api-key"' >> ~/.zshrc
source ~/.zshrc

# Windows PowerShell
$env:GOOGLE_API_KEY="your-api-key"

# 일시적 설정
GOOGLE_API_KEY="your-api-key" cui-server
```

#### 음성 인식 사용법
```markdown
1. 마이크 아이콘 클릭
2. 브라우저에서 마이크 권한 허용
3. 명확하게 말하기 (긴 문장도 정확히 인식)
4. 음성 인식 완료 후 텍스트 확인 및 수정
5. 전송 버튼으로 Claude에게 전송
```

## 실제 사용 시나리오

### 1. 웹 개발 프로젝트

#### 프론트엔드 개발
```typescript
// 1. 새 React 컴포넌트 생성 요청
"새로운 사용자 프로필 컴포넌트를 만들어줘. 
TypeScript와 Tailwind CSS를 사용하고, 
프로필 이미지, 이름, 이메일, 역할을 표시해야 해."

// 2. 파일 참조하며 수정 요청
"@src/components/UserProfile.tsx 이 컴포넌트에 
편집 모드 기능을 추가해줘. 더블클릭하면 편집 가능하게."

// 3. 스타일링 개선
"@src/styles/globals.css 전체적인 디자인 시스템을 
Material Design 3 기준으로 업데이트해줘."
```

#### 백엔드 API 개발
```typescript
// 병렬로 여러 태스크 실행
// 태스크 1: API 라우트 개발
"RESTful API를 만들어줘:
- GET /api/users - 사용자 목록
- POST /api/users - 사용자 생성  
- PUT /api/users/:id - 사용자 수정
- DELETE /api/users/:id - 사용자 삭제"

// 태스크 2: 데이터베이스 스키마
"Prisma 스키마를 설계해줘:
- User 모델 (id, email, name, role, createdAt)
- 적절한 인덱스와 관계 설정"

// 태스크 3: 인증 시스템
"NextAuth.js를 사용한 인증 시스템 구현:
- Google OAuth
- JWT 토큰 관리
- 역할 기반 접근 제어"
```

### 2. 데이터 분석 프로젝트

#### 데이터 전처리
```python
# 음성 인식을 활용한 자연스러운 요청
🎤 "판다스를 사용해서 CSV 파일을 읽고, 
결측치를 처리하고, 이상치를 탐지하는 
데이터 전처리 파이프라인을 만들어줘"

# Claude의 응답을 실시간으로 확인하면서
# 추가 요구사항 즉시 전달
"시각화도 추가해줘. 
분포도와 상관관계 히트맵도 보고 싶어"
```

#### 머신러닝 모델링
```python
# 백그라운드에서 여러 실험 동시 진행
# 태스크 A: 모델 학습
"scikit-learn으로 분류 모델을 만들어줘.
Random Forest, SVM, XGBoost 비교 분석"

# 태스크 B: 피처 엔지니어링  
"피처 중요도 분석하고 새로운 피처 생성해줘"

# 태스크 C: 모델 평가
"교차 검증과 다양한 메트릭으로 모델 평가해줘"
```

### 3. 문서화 및 테스트

#### 자동 문서 생성
```markdown
# 기존 코드베이스 문서화
"/init 프로젝트 전체 코드를 분석해서 
README.md, API 문서, 사용자 가이드를 생성해줘"

# 컴포넌트별 상세 문서
"@src/components/ 폴더의 모든 컴포넌트에 대해 
JSDoc 주석과 Storybook 스토리를 만들어줘"
```

#### 테스트 코드 작성
```javascript
// 포크 기능을 활용한 테스트 전략
// 원본 태스크: 기본 유닛 테스트
"Jest를 사용해서 모든 함수의 유닛 테스트를 작성해줘"

// 포크 1: 통합 테스트
"API 엔드포인트의 통합 테스트도 추가해줘"

// 포크 2: E2E 테스트
"Playwright로 주요 사용자 플로우의 E2E 테스트 작성"
```

## 팀 협업 워크플로우

### 1. 공유 개발 환경

#### 팀 서버 설정
```bash
# 팀 전용 서버 구성
# docker-compose.yml
version: '3.8'
services:
  cui-server:
    image: node:20-alpine
    ports:
      - "3001:3001"
    volumes:
      - ./cui-config:/root/.cui
      - ./projects:/workspace
    environment:
      - GOOGLE_API_KEY=${GOOGLE_API_KEY}
    command: npx cui-server --host 0.0.0.0
```

#### 접근 권한 관리
```json
// config.json - 팀별 설정
{
  "server": {
    "host": "0.0.0.0",
    "port": 3001,
    "authTokens": {
      "dev-team": "dev-team-token-2024",
      "design-team": "design-team-token-2024",
      "qa-team": "qa-team-token-2024"
    }
  },
  "workspaces": {
    "dev": "/workspace/development",
    "staging": "/workspace/staging",
    "docs": "/workspace/documentation"
  }
}
```

### 2. 코드 리뷰 워크플로우

#### 리뷰 요청 자동화
```typescript
// Claude를 활용한 자동 코드 리뷰
"다음 PR을 리뷰해줘:
- 코드 품질 검사
- 보안 취약점 확인
- 성능 최적화 제안
- 테스트 커버리지 분석

@src/components/NewFeature.tsx
@tests/NewFeature.test.tsx"
```

#### 리뷰 피드백 적용
```typescript
// 리뷰 댓글을 바탕으로 수정
"코드 리뷰에서 지적된 다음 사항들을 수정해줘:
1. useState 대신 useReducer 사용
2. 메모이제이션 최적화
3. 에러 바운더리 추가
4. 접근성 개선"
```

## 문제 해결 및 디버깅

### 1. 일반적인 문제

#### 서버 시작 오류
```bash
# 포트 충돌 해결
lsof -ti:3001 | xargs kill -9
cui-server --port 3002

# 권한 오류 해결
sudo chown -R $(whoami) ~/.cui
chmod 755 ~/.cui
```

#### Claude Code 연결 문제
```bash
# Claude Code 재로그인
claude auth logout
claude auth login

# API 키 확인
claude auth status

# 설정 초기화
rm -rf ~/.claude
claude auth login
```

### 2. 성능 최적화

#### 메모리 사용량 최적화
```json
// config.json - 성능 설정
{
  "performance": {
    "maxConcurrentTasks": 3,
    "messageHistoryLimit": 1000,
    "autoArchiveAfterDays": 30,
    "enableCodeCache": true
  }
}
```

#### 네트워크 최적화
```javascript
// 청크 단위 스트리밍 설정
const streamConfig = {
  chunkSize: 1024,
  timeout: 30000,
  retryAttempts: 3,
  enableCompression: true
};
```

### 3. 보안 강화

#### HTTPS 설정 (Nginx 예제)
```nginx
# /etc/nginx/sites-available/cui
server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_cache_bypass $http_upgrade;
    }
}
```

#### 방화벽 설정
```bash
# UFW 설정 (Ubuntu)
sudo ufw allow 22/tcp      # SSH
sudo ufw allow 80/tcp      # HTTP
sudo ufw allow 443/tcp     # HTTPS
sudo ufw deny 3001/tcp     # CUI 직접 접근 차단
sudo ufw enable

# 특정 IP만 허용
sudo ufw allow from 192.168.1.0/24 to any port 3001
```

## 확장 및 커스터마이징

### 1. 플러그인 개발

#### 커스텀 명령어 추가
```typescript
// src/plugins/customCommands.ts
interface CustomCommand {
  name: string;
  description: string;
  execute: (args: string[]) => Promise<string>;
}

const customCommands: CustomCommand[] = [
  {
    name: '/deploy',
    description: 'Deploy current project',
    execute: async (args) => {
      const environment = args[0] || 'staging';
      return `Deploying to ${environment}...`;
    }
  },
  {
    name: '/analyze',
    description: 'Analyze code complexity',
    execute: async (args) => {
      const directory = args[0] || '.';
      return `Analyzing ${directory} for complexity metrics...`;
    }
  }
];
```

#### 테마 커스터마이징
```css
/* src/styles/themes/custom.css */
:root[data-theme='custom'] {
  --primary-color: #6366f1;
  --secondary-color: #8b5cf6;
  --background-color: #0f172a;
  --surface-color: #1e293b;
  --text-color: #f1f5f9;
  --border-color: #334155;
  --accent-color: #06b6d4;
  --success-color: #10b981;
  --warning-color: #f59e0b;
  --error-color: #ef4444;
}

.chat-message {
  background: var(--surface-color);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 1rem;
  margin: 0.5rem 0;
}

.code-block {
  background: rgba(0, 0, 0, 0.3);
  border-radius: 6px;
  padding: 1rem;
  font-family: 'JetBrains Mono', monospace;
}
```

### 2. API 통합

#### 외부 서비스 연동
```typescript
// src/integrations/github.ts
class GitHubIntegration {
  constructor(private token: string) {}
  
  async createPullRequest(
    repo: string,
    title: string,
    body: string,
    head: string,
    base: string = 'main'
  ) {
    const response = await fetch(`https://api.github.com/repos/${repo}/pulls`, {
      method: 'POST',
      headers: {
        'Authorization': `token ${this.token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ title, body, head, base })
    });
    
    return response.json();
  }
  
  async createIssue(repo: string, title: string, body: string) {
    const response = await fetch(`https://api.github.com/repos/${repo}/issues`, {
      method: 'POST',
      headers: {
        'Authorization': `token ${this.token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ title, body })
    });
    
    return response.json();
  }
}

// 사용 예제
const github = new GitHubIntegration(process.env.GITHUB_TOKEN!);

// Claude와 연동하여 자동 PR 생성
export const createAutoPR = async (changes: string, description: string) => {
  const prTitle = `Auto-generated changes: ${description}`;
  const prBody = `This PR contains the following changes:\n\n${changes}`;
  
  return await github.createPullRequest(
    'your-org/your-repo',
    prTitle,
    prBody,
    'feature/auto-changes'
  );
};
```

### 3. 데이터 백업 및 동기화

#### 세션 데이터 백업
```typescript
// src/utils/backup.ts
interface BackupConfig {
  destination: 'local' | 'cloud' | 's3';
  schedule: string; // cron expression
  retention: number; // days
}

class BackupManager {
  constructor(private config: BackupConfig) {}
  
  async backupSessions() {
    const sessions = await this.loadAllSessions();
    const timestamp = new Date().toISOString();
    const backupData = {
      timestamp,
      version: '1.0',
      sessions
    };
    
    switch (this.config.destination) {
      case 'local':
        await this.saveLocal(backupData, timestamp);
        break;
      case 's3':
        await this.saveToS3(backupData, timestamp);
        break;
      case 'cloud':
        await this.saveToCloud(backupData, timestamp);
        break;
    }
  }
  
  private async saveLocal(data: any, timestamp: string) {
    const fs = require('fs').promises;
    const path = require('path');
    
    const backupDir = path.join(process.env.HOME!, '.cui', 'backups');
    await fs.mkdir(backupDir, { recursive: true });
    
    const filename = `cui-backup-${timestamp}.json`;
    const filepath = path.join(backupDir, filename);
    
    await fs.writeFile(filepath, JSON.stringify(data, null, 2));
    console.log(`Backup saved to ${filepath}`);
  }
}

// 자동 백업 스케줄링
import cron from 'node-cron';

const backupManager = new BackupManager({
  destination: 'local',
  schedule: '0 2 * * *', // 매일 새벽 2시
  retention: 30
});

cron.schedule(backupManager.config.schedule, () => {
  backupManager.backupSessions();
});
```

## 결론

CUI (Claude Code Web UI)는 **Claude Code의 강력한 기능을 웹 환경으로 완벽히 이식**한 혁신적인 도구입니다. 단순한 웹 래퍼가 아닌, **병렬 처리**, **태스크 관리**, **실시간 알림**, **음성 인식** 등의 고급 기능을 통해 개발 생산성을 대폭 향상시킵니다.

### 🎯 핵심 가치

1. **접근성 향상**: CLI에서 웹 브라우저로, 언제 어디서나 접근
2. **생산성 극대화**: 병렬 태스크 실행으로 동시 작업 처리
3. **협업 강화**: 팀 공유 환경과 원격 접속 지원
4. **사용자 경험**: 모던 UI와 직관적인 인터페이스

### 🚀 활용 시나리오

- **개인 개발자**: 다양한 프로젝트 동시 관리
- **팀 개발**: 공유 환경에서 협업 개발
- **원격 작업**: 어디서나 접근 가능한 클라우드 환경
- **교육**: 웹 기반 코딩 교육 플랫폼

### 💡 미래 전망

CUI는 지속적으로 발전하고 있으며, **플러그인 시스템**, **고급 협업 기능**, **더 많은 AI 모델 지원** 등의 기능이 추가될 예정입니다. Claude Code를 사용하는 모든 개발자에게 **더 나은 개발 경험**을 제공하는 필수 도구가 될 것입니다.

CUI를 통해 CLI의 제약을 벗어나 **모던하고 효율적인 AI 협업 환경**을 경험해보시기 바랍니다! 🚀✨

---

> **참고 자료**
> - [CUI GitHub Repository](https://github.com/wbopan/cui)
> - [Claude Code 공식 문서](https://claude.ai/docs)
> - [Anthropic API 문서](https://docs.anthropic.com)
> - [ntfy 공식 사이트](https://ntfy.sh)