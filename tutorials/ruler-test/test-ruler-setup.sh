#!/bin/bash
# test-ruler-setup.sh

echo "🚀 Ruler 테스트 환경 설정 시작"
echo "===================================="

# 시스템 요구사항 확인
echo "[INFO] 시스템 요구사항 확인 중..."

# Node.js 확인
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "[SUCCESS] Node.js 설치됨: $NODE_VERSION"
else
    echo "[ERROR] Node.js가 설치되지 않음. brew install node 실행 필요"
    exit 1
fi

# npm 확인
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo "[SUCCESS] npm 설치됨: $NPM_VERSION"
else
    echo "[ERROR] npm이 설치되지 않음"
    exit 1
fi

# 테스트 디렉토리 생성
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
TEST_DIR="$HOME/ruler-test-$TIMESTAMP"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "[INFO] 테스트 디렉토리 생성: $TEST_DIR"

# Ruler 설치 확인 및 설치
echo "[INFO] Ruler 설치 확인 중..."
if command -v ruler &> /dev/null; then
    RULER_VERSION=$(ruler --version)
    echo "[SUCCESS] Ruler 이미 설치됨: $RULER_VERSION"
else
    echo "[INFO] Ruler 설치 중..."
    npm install -g @intellectronica/ruler
    
    if command -v ruler &> /dev/null; then
        RULER_VERSION=$(ruler --version)
        echo "[SUCCESS] Ruler 설치 완료: $RULER_VERSION"
    else
        echo "[ERROR] Ruler 설치 실패"
        exit 1
    fi
fi

# 샘플 프로젝트 초기화
echo "[INFO] 샘플 TypeScript 프로젝트 초기화 중..."
npm init -y
npm install express typescript @types/node @types/express ts-node

# package.json 업데이트
cat > package.json << 'EOF'
{
  "name": "ruler-test-project",
  "version": "1.0.0",
  "description": "Ruler AI assistant configuration test project",
  "main": "src/index.ts",
  "scripts": {
    "dev": "ts-node src/index.ts",
    "build": "tsc",
    "ruler:apply": "ruler apply",
    "ruler:status": "ruler status",
    "ruler:verbose": "ruler apply --verbose"
  },
  "dependencies": {
    "express": "^4.18.2",
    "typescript": "^5.0.0",
    "@types/node": "^20.0.0",
    "@types/express": "^4.17.17",
    "ts-node": "^10.9.0"
  }
}
EOF

# TypeScript 설정
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

# 샘플 소스 코드 생성
mkdir -p src
cat > src/index.ts << 'EOF'
import express from 'express';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'Ruler test API is running!' });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
EOF

# Ruler 초기화
echo "[INFO] Ruler 초기화 중..."
ruler init

# 커스텀 규칙 파일들 생성
echo "[INFO] 커스텀 규칙 파일들 생성 중..."

cat > .ruler/typescript_standards.md << 'EOF'
# TypeScript Development Standards

## Type Safety Guidelines
- Always use explicit type annotations for function parameters and return values
- Prefer interfaces over type aliases for object shapes
- Use readonly for immutable data structures
- Implement proper error handling with Result<T, E> pattern

## Code Organization
- Use barrel exports (index.ts) for clean imports
- Group related functionality in dedicated modules
- Implement dependency injection for better testability
- Follow single responsibility principle

## Performance Best Practices
- Use const assertions for literal types
- Implement proper memoization for expensive calculations
- Minimize bundle size with tree shaking
- Use lazy loading for heavy components

## Express.js Specific Rules
- Use express.Router() for modular route organization
- Implement middleware for cross-cutting concerns
- Validate request parameters with zod or joi
- Use async/await consistently for asynchronous operations
EOF

cat > .ruler/coding_conventions.md << 'EOF'
# Team Coding Conventions

## Naming Conventions
- Use camelCase for variables and functions
- Use PascalCase for classes and interfaces
- Use UPPER_SNAKE_CASE for constants
- Use kebab-case for file names

## Function Guidelines
- Functions should be pure when possible
- Keep functions small and focused (< 20 lines)
- Use descriptive parameter names
- Include JSDoc comments for public APIs

## Error Handling
- Always handle promises with try-catch or .catch()
- Return meaningful error messages
- Log errors with appropriate context
- Use custom error classes for domain-specific errors

## Testing Requirements
- Write unit tests for all business logic
- Use descriptive test names
- Mock external dependencies
- Maintain minimum 80% code coverage
EOF

cat > .ruler/api_development.md << 'EOF'
# API Development Guidelines

## REST API Standards
- Use appropriate HTTP methods (GET, POST, PUT, DELETE)
- Return consistent response formats
- Implement proper HTTP status codes
- Include request/response validation

## Security Requirements
- Validate and sanitize all user inputs
- Implement rate limiting
- Use HTTPS in production
- Never expose sensitive data in responses

## Documentation
- Use OpenAPI/Swagger for API documentation
- Include example requests and responses
- Document error scenarios
- Keep documentation up-to-date with code changes

## Performance Optimization
- Implement database query optimization
- Use appropriate caching strategies
- Minimize response payload size
- Monitor API response times
EOF

cat > .ruler/project_context.md << 'EOF'
# Project Context Information

## Tech Stack
- Runtime: Node.js with TypeScript
- Framework: Express.js
- Database: PostgreSQL (planned)
- Testing: Jest + Supertest
- Deployment: Docker + Kubernetes

## Project Structure
```
src/
├── controllers/     # Route handlers
├── middleware/      # Express middleware
├── models/         # Data models
├── routes/         # Route definitions
├── services/       # Business logic
├── utils/          # Utility functions
└── types/          # TypeScript type definitions
```

## Key Features
- RESTful API endpoints
- User authentication and authorization
- Data validation and sanitization
- Error handling and logging
- Health check endpoints

## Development Workflow
- Use feature branches for development
- Require code review for all changes
- Run tests before merging
- Follow semantic versioning
EOF

# MCP 설정 파일 생성
cat > .ruler/mcp.json << 'EOF'
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "."
      ]
    },
    "git": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-git", "--repository", "."]
    }
  }
}
EOF

# 규칙 적용
echo "[INFO] Ruler 규칙 적용 중..."
ruler apply --verbose

# 생성된 파일들 확인
echo ""
echo "📁 생성된 AI 설정 파일들:"
echo "=========================="

FILES_FOUND=0

if [ -f ".github/copilot-instructions.md" ]; then
    echo "✅ GitHub Copilot: .github/copilot-instructions.md"
    FILES_FOUND=$((FILES_FOUND + 1))
fi

if [ -f "CLAUDE.md" ]; then
    echo "✅ Claude: CLAUDE.md"
    FILES_FOUND=$((FILES_FOUND + 1))
fi

if [ -f ".cursor/rules/ruler_cursor_instructions.mdc" ]; then
    echo "✅ Cursor: .cursor/rules/ruler_cursor_instructions.mdc"
    FILES_FOUND=$((FILES_FOUND + 1))
fi

if [ -f "ruler_aider_instructions.md" ]; then
    echo "✅ Aider: ruler_aider_instructions.md"
    FILES_FOUND=$((FILES_FOUND + 1))
fi

if [ -f ".aider.conf.yml" ]; then
    echo "✅ Aider Config: .aider.conf.yml"
    FILES_FOUND=$((FILES_FOUND + 1))
fi

echo ""
echo "총 $FILES_FOUND 개의 AI 설정 파일이 생성되었습니다."

# 샘플 설정 파일 내용 미리보기
echo ""
echo "📋 GitHub Copilot 설정 파일 미리보기 (처음 15줄):"
echo "=================================================="
if [ -f ".github/copilot-instructions.md" ]; then
    head -n 15 .github/copilot-instructions.md
else
    echo "GitHub Copilot 설정 파일이 생성되지 않았습니다."
fi

echo ""
echo "📋 Cursor 설정 파일 미리보기 (처음 15줄):"
echo "========================================"
if [ -f ".cursor/rules/ruler_cursor_instructions.mdc" ]; then
    head -n 15 .cursor/rules/ruler_cursor_instructions.mdc
else
    echo "Cursor 설정 파일이 생성되지 않았습니다."
fi

# 테스트 스크립트 생성
cat > test-ruler-commands.sh << 'EOF'
#!/bin/bash
echo "🧪 Ruler 명령어 테스트"
echo "===================="

echo "1. Ruler 상태 확인"
ruler status
echo ""

echo "2. 사용 가능한 에이전트 목록"
ruler list-agents
echo ""

echo "3. 특정 에이전트에만 적용 (Cursor)"
ruler apply --agents cursor
echo ""

echo "4. 여러 에이전트에 적용 (Copilot + Claude)"
ruler apply --agents copilot,claude
echo ""

echo "5. 모든 에이전트에 재적용 (상세 로그)"
ruler apply --verbose
echo ""

echo "6. .gitignore 업데이트 제외 적용"
ruler apply --no-gitignore
echo ""

echo "✅ 모든 테스트 명령어 실행 완료!"
EOF

chmod +x test-ruler-commands.sh

# 편의 스크립트들 생성
cat > quick-commands.txt << 'EOF'
# Ruler 빠른 명령어 모음

## 기본 명령어
ruler --version                 # 버전 확인
ruler status                    # 현재 상태 확인
ruler list-agents              # 사용 가능한 에이전트 목록

## 규칙 적용
ruler apply                     # 모든 에이전트에 적용
ruler apply --verbose          # 상세 로그와 함께 적용
ruler apply --agents cursor    # Cursor에만 적용
ruler apply --agents copilot,claude  # 여러 에이전트에 적용

## 파일 편집
code .ruler/                   # 규칙 파일들 편집
code .ruler/ruler.toml         # 설정 파일 편집

## 디버깅
ruler apply --no-gitignore     # .gitignore 업데이트 제외
find . -name "*copilot*" -o -name "*claude*" -o -name "*cursor*"  # 생성된 파일 찾기

## npm 스크립트 사용
npm run ruler:apply            # package.json의 스크립트 실행
npm run ruler:status           # 상태 확인 스크립트
npm run ruler:verbose          # 상세 로그 스크립트
EOF

# 환경 정보 저장
cat > test-environment.txt << EOF
Ruler 테스트 환경 정보
====================

생성 시간: $(date)
Node.js 버전: $(node --version)
npm 버전: $(npm --version)
Ruler 버전: $(ruler --version 2>/dev/null || echo "설치 실패")
운영체제: $(uname -a)
테스트 디렉토리: $TEST_DIR

Ruler 설정 상태:
$(ruler status 2>/dev/null || echo "Ruler 상태 확인 실패")

생성된 파일 목록:
$(find . -name "*.md" -o -name "*.yml" -o -name "*.mdc" -o -name "*.toml" | sort)

AI 설정 파일들:
$(find . -name "*copilot*" -o -name "*claude*" -o -name "*cursor*" -o -name "*aider*" 2>/dev/null | sort)
EOF

echo ""
echo "🎉 Ruler 테스트 환경 설정 완료!"
echo "================================"
echo ""
echo "📁 테스트 디렉토리: $TEST_DIR"
echo ""
echo "🚀 다음 단계:"
echo "1. cd $TEST_DIR"
echo "2. ./test-ruler-commands.sh - 자동 테스트 실행"
echo "3. quick-commands.txt - 수동 테스트 명령어 참고"
echo "4. code .ruler/ - 규칙 파일들 편집해보기"
echo ""
echo "📋 생성된 유용한 파일들:"
echo "- test-ruler-commands.sh: 자동 테스트 스크립트"
echo "- quick-commands.txt: 빠른 명령어 레퍼런스"
echo "- test-environment.txt: 테스트 환경 정보"
echo "- package.json: npm 스크립트 포함"
echo ""
echo "💡 팁:"
echo "- 'ruler apply --verbose'로 상세한 실행 과정 확인"
echo "- 'ruler status'로 현재 설정 상태 점검"
echo "- '.ruler/' 폴더의 마크다운 파일들 편집하여 규칙 커스터마이징"

# 사용자에게 바로 테스트 실행 여부 확인
echo ""
read -p "지금 Ruler 테스트를 실행해보시겠습니까? (y/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🧪 Ruler 테스트 실행 중..."
    echo "========================="
    
    # 기본 테스트들 실행
    echo "1. Ruler 상태 확인:"
    ruler status
    
    echo ""
    echo "2. 에이전트 목록 확인:"
    ruler list-agents
    
    echo ""
    echo "3. 규칙 재적용 (상세 로그):"
    ruler apply --verbose
    
    echo ""
    echo "4. 생성된 파일 확인:"
    find . -name "*copilot*" -o -name "*claude*" -o -name "*cursor*" -o -name "*aider*" | sort
    
    echo ""
    echo "✅ 기본 테스트 완료!"
    echo "더 많은 테스트를 원하시면 ./test-ruler-commands.sh를 실행하세요."
else
    echo ""
    echo "[SUCCESS] 테스트 환경 준비 완료!"
    echo "언제든지 다음 명령어들로 테스트를 시작하세요:"
    echo "- ./test-ruler-commands.sh (자동 테스트)"
    echo "- ruler apply --verbose (수동 테스트)"
    echo "- cat quick-commands.txt (명령어 참고)"
fi

echo ""
echo "🎯 테스트 완료 후 할 일:"
echo "1. 생성된 AI 설정 파일들 내용 확인"
echo "2. 실제 AI 도구에서 설정이 적용되는지 테스트"
echo "3. .ruler/ 폴더의 규칙 파일들 수정해보기"
echo "4. 'ruler apply' 실행하여 변경사항 반영 확인"
