#!/bin/bash

# Kiro AI IDE 설치 및 테스트 스크립트
# 작성일: 2025-07-17
# 작성자: Thaki Cloud Team

set -e  # 오류 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 시스템 요구사항 검사
check_system_requirements() {
    log_info "시스템 요구사항 검사 중..."
    
    # macOS 버전 확인
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "이 스크립트는 macOS에서만 실행됩니다."
        exit 1
    fi
    
    # macOS 버전 체크
    macos_version=$(sw_vers -productVersion)
    log_info "macOS 버전: $macos_version"
    
    # 메모리 확인
    memory_gb=$(system_profiler SPHardwareDataType | grep "Memory:" | awk '{print $2}')
    log_info "시스템 메모리: $memory_gb"
    
    # Homebrew 설치 확인
    if ! command -v brew &> /dev/null; then
        log_warning "Homebrew가 설치되지 않았습니다. 설치를 진행합니다..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        log_success "Homebrew가 이미 설치되어 있습니다."
    fi
}

# Kiro 설치
install_kiro() {
    log_info "Kiro AI IDE 설치 중..."
    
    # 현재는 Kiro가 정식 출시되지 않아서 가상의 설치 과정을 시뮬레이션
    # 실제 출시 시에는 아래 명령어로 설치 가능할 예정
    
    # brew install --cask kiro
    
    # 임시로 설치 시뮬레이션
    log_warning "Kiro는 아직 정식 출시되지 않았습니다. 설치 프로세스를 시뮬레이션합니다..."
    
    # 가상의 설치 디렉토리 생성
    mkdir -p ~/.kiro/bin
    mkdir -p ~/.kiro/templates
    mkdir -p ~/.kiro/hooks
    
    # 가상의 설정 파일 생성
    cat > ~/.kiro/settings.json << 'EOF'
{
  "ai": {
    "model": "claude-4",
    "temperature": 0.3,
    "maxTokens": 4096
  },
  "specs": {
    "autoSave": true,
    "templatePath": "~/.kiro/templates",
    "defaultRequirementsFormat": "EARS"
  },
  "hooks": {
    "autoExecute": true,
    "allowShellCommands": true,
    "maxExecutionTime": 300
  },
  "integration": {
    "git": {
      "autoCommit": false,
      "commitMessageTemplate": "{type}: {description}"
    },
    "testing": {
      "framework": "jest",
      "coverage": true,
      "e2eFramework": "playwright"
    }
  }
}
EOF
    
    log_success "Kiro 설정 파일이 생성되었습니다: ~/.kiro/settings.json"
}

# 테스트 프로젝트 생성
create_test_project() {
    log_info "Kiro 테스트 프로젝트 생성 중..."
    
    PROJECT_DIR="$HOME/kiro-test-project"
    
    # 기존 프로젝트 디렉토리가 있으면 제거
    if [ -d "$PROJECT_DIR" ]; then
        log_warning "기존 테스트 프로젝트를 제거합니다..."
        rm -rf "$PROJECT_DIR"
    fi
    
    # 새 프로젝트 디렉토리 생성
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR"
    
    # Kiro 프로젝트 구조 생성
    mkdir -p specs/user-auth
    mkdir -p hooks
    mkdir -p src
    mkdir -p tests
    
    # package.json 생성
    cat > package.json << 'EOF'
{
  "name": "kiro-test-project",
  "version": "1.0.0",
  "description": "Kiro AI IDE 테스트 프로젝트",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "test": "jest",
    "dev": "nodemon src/index.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "jsonwebtoken": "^9.0.0",
    "bcrypt": "^5.1.0"
  },
  "devDependencies": {
    "jest": "^29.0.0",
    "nodemon": "^3.0.0"
  }
}
EOF
    
    log_success "테스트 프로젝트가 생성되었습니다: $PROJECT_DIR"
}

# Spec 파일 생성
create_spec_files() {
    log_info "Spec 파일들을 생성하는 중..."
    
    # requirements.md 생성
    cat > specs/user-auth/requirements.md << 'EOF'
# 사용자 인증 기능 요구사항

## 사용자 스토리

### 회원가입
- **As a** 새로운 사용자
- **I want to** 이메일과 비밀번호로 계정을 생성할 수 있다
- **So that** 개인화된 할일 목록을 관리할 수 있다

**승인 기준:**
- 이메일 형식 검증 (RFC 5322 표준)
- 비밀번호 최소 8자, 특수문자 1개 이상 포함
- 중복 이메일 가입 방지
- 성공 시 자동 로그인 처리

### 로그인
- **As a** 기존 사용자  
- **I want to** 이메일과 비밀번호로 로그인할 수 있다
- **So that** 내 할일 목록에 접근할 수 있다

**승인 기준:**
- 잘못된 자격 증명 시 명확한 오류 메시지
- 로그인 상태 7일간 유지 (Remember Me 옵션)
- 브루트 포스 공격 방지 (5회 실패 시 10분 잠금)

## 비기능적 요구사항

- 응답 시간: 2초 이내
- 보안: HTTPS 필수, JWT 토큰 기반 인증
- 접근성: WCAG 2.1 AA 수준 준수
EOF

    # design.md 생성
    cat > specs/user-auth/design.md << 'EOF'
# 사용자 인증 시스템 설계

## 아키텍처 개요

```
Frontend (React) --> API Gateway --> Auth Service --> Database
                                  --> JWT Service
```

## 기술 스택

### Backend
- **Node.js** with Express
- **bcrypt** for password hashing
- **jsonwebtoken** for JWT handling
- **SQLite** for development (PostgreSQL for production)

## API 설계

### POST `/api/auth/register`
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "confirmPassword": "SecurePass123!"
}
```

### POST `/api/auth/login`  
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "rememberMe": true
}
```

## 보안 고려사항

1. **비밀번호 해싱**: bcrypt with salt rounds 12
2. **JWT 토큰**: 15분 만료, Refresh token 7일
3. **Rate Limiting**: IP당 분당 10회 요청 제한
4. **CORS**: 허용된 도메인만 접근 가능
EOF

    # tasks.md 생성
    cat > specs/user-auth/tasks.md << 'EOF'
# 사용자 인증 구현 작업 목록

## Backend 작업

### 1. 프로젝트 초기 설정
- [x] Express 서버 설정
- [x] 환경 변수 설정 (.env)
- [ ] 데이터베이스 연결 설정
- [ ] 미들웨어 설정

### 2. 인증 기능
- [ ] 비밀번호 해싱 유틸리티
- [ ] JWT 생성/검증 유틸리티
- [ ] POST /api/auth/register
- [ ] POST /api/auth/login

### 3. 보안 강화
- [ ] Rate limiting 미들웨어
- [ ] Input validation
- [ ] Error handling

## 테스트 작업

### 1. 단위 테스트
- [ ] 인증 유틸리티 함수 테스트
- [ ] API 핸들러 테스트

### 2. 통합 테스트
- [ ] 회원가입 플로우 테스트
- [ ] 로그인 플로우 테스트
EOF

    log_success "Spec 파일들이 생성되었습니다."
}

# Hook 파일 생성
create_hook_files() {
    log_info "Hook 파일들을 생성하는 중..."
    
    # 파일 저장 시 자동 포맷팅 Hook
    cat > hooks/on-file-save.js << 'EOF'
// 파일 저장 시 자동으로 실행되는 후크
module.exports = {
  name: 'Auto Format and Lint',
  trigger: 'file:save',
  filter: ['*.js', '*.ts', '*.json'],
  
  async execute(context) {
    const { filePath, fileContent } = context;
    
    console.log(`Processing file: ${filePath}`);
    
    // 간단한 포맷팅 시뮬레이션
    if (filePath.endsWith('.js')) {
      console.log('Running ESLint...');
      console.log('Running Prettier...');
    }
    
    if (filePath.includes('src/')) {
      console.log('Running related tests...');
    }
    
    console.log('File processing completed.');
  }
};
EOF

    # Spec 완료 시 문서 업데이트 Hook
    cat > hooks/spec-completion.js << 'EOF'
// Spec 작업 완료 시 자동으로 문서 업데이트
module.exports = {
  name: 'Update Documentation',
  trigger: 'spec:task-completed',
  
  async execute(context) {
    const { specName, completedTask } = context;
    
    console.log(`Task completed: ${completedTask} in ${specName}`);
    
    // README.md 업데이트 시뮬레이션
    console.log('Updating README.md...');
    console.log('Creating git commit...');
    
    console.log('Documentation update completed.');
  }
};
EOF

    log_success "Hook 파일들이 생성되었습니다."
}

# 기본 애플리케이션 코드 생성
create_sample_code() {
    log_info "샘플 애플리케이션 코드를 생성하는 중..."
    
    # Express 서버 기본 구조
    cat > src/index.js << 'EOF'
const express = require('express');
const authRoutes = require('./routes/auth');

const app = express();
const PORT = process.env.PORT || 3000;

// 미들웨어
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 라우트
app.use('/api/auth', authRoutes);

app.get('/', (req, res) => {
  res.json({ 
    message: 'Kiro 테스트 프로젝트에 오신 것을 환영합니다!',
    timestamp: new Date().toISOString(),
    endpoints: [
      'POST /api/auth/register',
      'POST /api/auth/login'
    ]
  });
});

app.listen(PORT, () => {
  console.log(`서버가 포트 ${PORT}에서 실행 중입니다.`);
  console.log(`http://localhost:${PORT}에서 확인하세요.`);
});

module.exports = app;
EOF

    # 인증 라우트
    mkdir -p src/routes
    cat > src/routes/auth.js << 'EOF'
const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const router = express.Router();

// 임시 사용자 저장소 (실제로는 데이터베이스 사용)
const users = [];

// 회원가입
router.post('/register', async (req, res) => {
  try {
    const { email, password, confirmPassword } = req.body;
    
    // 기본 검증
    if (!email || !password || !confirmPassword) {
      return res.status(400).json({ error: '모든 필드를 입력해주세요.' });
    }
    
    if (password !== confirmPassword) {
      return res.status(400).json({ error: '비밀번호가 일치하지 않습니다.' });
    }
    
    // 이메일 중복 검사
    const existingUser = users.find(user => user.email === email);
    if (existingUser) {
      return res.status(400).json({ error: '이미 존재하는 이메일입니다.' });
    }
    
    // 비밀번호 해싱
    const hashedPassword = await bcrypt.hash(password, 12);
    
    // 사용자 생성
    const user = {
      id: Date.now().toString(),
      email,
      password: hashedPassword,
      createdAt: new Date().toISOString()
    };
    
    users.push(user);
    
    // JWT 토큰 생성
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      'secret-key',
      { expiresIn: '7d' }
    );
    
    res.status(201).json({
      message: '회원가입이 완료되었습니다.',
      user: {
        id: user.id,
        email: user.email,
        createdAt: user.createdAt
      },
      token
    });
    
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: '서버 오류가 발생했습니다.' });
  }
});

// 로그인
router.post('/login', async (req, res) => {
  try {
    const { email, password, rememberMe } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({ error: '이메일과 비밀번호를 입력해주세요.' });
    }
    
    // 사용자 찾기
    const user = users.find(user => user.email === email);
    if (!user) {
      return res.status(401).json({ error: '잘못된 이메일 또는 비밀번호입니다.' });
    }
    
    // 비밀번호 검증
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return res.status(401).json({ error: '잘못된 이메일 또는 비밀번호입니다.' });
    }
    
    // JWT 토큰 생성
    const expiresIn = rememberMe ? '7d' : '15m';
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      'secret-key',
      { expiresIn }
    );
    
    res.json({
      message: '로그인이 완료되었습니다.',
      user: {
        id: user.id,
        email: user.email
      },
      token
    });
    
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: '서버 오류가 발생했습니다.' });
  }
});

module.exports = router;
EOF

    # 테스트 파일
    cat > tests/auth.test.js << 'EOF'
const request = require('supertest');
const app = require('../src/index');

describe('Auth API', () => {
  describe('POST /api/auth/register', () => {
    test('성공적인 회원가입', async () => {
      const userData = {
        email: 'test@example.com',
        password: 'SecurePass123!',
        confirmPassword: 'SecurePass123!'
      };
      
      const response = await request(app)
        .post('/api/auth/register')
        .send(userData);
      
      expect(response.status).toBe(201);
      expect(response.body.message).toBe('회원가입이 완료되었습니다.');
      expect(response.body.user.email).toBe(userData.email);
      expect(response.body.token).toBeDefined();
    });
    
    test('비밀번호 불일치', async () => {
      const userData = {
        email: 'test2@example.com', 
        password: 'SecurePass123!',
        confirmPassword: 'DifferentPass123!'
      };
      
      const response = await request(app)
        .post('/api/auth/register')
        .send(userData);
      
      expect(response.status).toBe(400);
      expect(response.body.error).toBe('비밀번호가 일치하지 않습니다.');
    });
  });
  
  describe('POST /api/auth/login', () => {
    test('성공적인 로그인', async () => {
      // 먼저 사용자 등록
      await request(app)
        .post('/api/auth/register')
        .send({
          email: 'login@example.com',
          password: 'SecurePass123!',
          confirmPassword: 'SecurePass123!'
        });
      
      // 로그인 시도
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'login@example.com',
          password: 'SecurePass123!'
        });
      
      expect(response.status).toBe(200);
      expect(response.body.message).toBe('로그인이 완료되었습니다.');
      expect(response.body.token).toBeDefined();
    });
  });
});
EOF

    log_success "샘플 애플리케이션 코드가 생성되었습니다."
}

# zshrc aliases 설정
setup_aliases() {
    log_info "zshrc aliases를 설정하는 중..."
    
    ALIAS_FILE="$HOME/.kiro_aliases"
    
    cat > "$ALIAS_FILE" << 'EOF'
# Kiro AI IDE Aliases
# 사용법: source ~/.kiro_aliases

# 프로젝트 관리
alias kiro-new="mkdir -p specs hooks src tests && echo 'Kiro 프로젝트 구조가 생성되었습니다.'"
alias kiro-specs="cd specs && ls -la"
alias kiro-hooks="cd hooks && ls -la"

# 개발 워크플로
alias kiro-start="npm start"
alias kiro-test="npm test"
alias kiro-dev="npm run dev"

# Spec 관리
alias spec-status="find specs -name '*.md' | wc -l && echo '개의 spec 파일이 있습니다.'"
alias spec-list="find specs -name '*.md' -exec basename {} .md \;"

# Git 통합
alias git-spec="git add specs/ && git commit -m 'docs: update spec'"
alias git-hook="git add hooks/ && git commit -m 'feat: add automation hook'"
alias git-kiro="git add . && git commit -m 'feat: kiro project update'"

# 유틸리티
alias kiro-tree="tree -I 'node_modules|.git'"
alias kiro-clean="rm -rf node_modules package-lock.json && npm install"

echo "✅ Kiro aliases가 로드되었습니다!"
echo "사용 가능한 명령어:"
echo "  kiro-new     - 새 Kiro 프로젝트 구조 생성"
echo "  kiro-specs   - specs 디렉토리로 이동"
echo "  kiro-hooks   - hooks 디렉토리로 이동"
echo "  kiro-start   - 애플리케이션 실행"
echo "  kiro-test    - 테스트 실행"
echo "  spec-status  - spec 파일 개수 확인"
echo "  git-kiro     - Kiro 프로젝트 변경사항 커밋"
EOF

    # .zshrc에 source 라인 추가 (중복 방지)
    if ! grep -q "source ~/.kiro_aliases" ~/.zshrc 2>/dev/null; then
        echo "" >> ~/.zshrc
        echo "# Kiro AI IDE Aliases" >> ~/.zshrc
        echo "source ~/.kiro_aliases" >> ~/.zshrc
        log_success "~/.zshrc에 Kiro aliases가 추가되었습니다."
    else
        log_info "Kiro aliases가 이미 ~/.zshrc에 설정되어 있습니다."
    fi
    
    log_success "Alias 설정 파일이 생성되었습니다: $ALIAS_FILE"
}

# 테스트 실행
run_tests() {
    log_info "테스트를 실행하는 중..."
    
    cd "$HOME/kiro-test-project"
    
    # npm 의존성 설치
    if [ ! -d "node_modules" ]; then
        log_info "npm 의존성을 설치하는 중..."
        npm install --silent
    fi
    
    # supertest 테스트 의존성 추가
    npm install --save-dev supertest --silent
    
    # 서버 백그라운드 실행
    log_info "테스트 서버를 시작하는 중..."
    npm start &
    SERVER_PID=$!
    
    # 서버 시작 대기
    sleep 3
    
    # API 테스트
    log_info "API 엔드포인트를 테스트하는 중..."
    
    # 기본 엔드포인트 테스트
    if curl -s http://localhost:3000 | grep -q "환영합니다"; then
        log_success "✅ 기본 엔드포인트 테스트 통과"
    else
        log_error "❌ 기본 엔드포인트 테스트 실패"
    fi
    
    # 회원가입 API 테스트
    REGISTER_RESPONSE=$(curl -s -X POST http://localhost:3000/api/auth/register \
        -H "Content-Type: application/json" \
        -d '{
            "email": "test@example.com",
            "password": "SecurePass123!",
            "confirmPassword": "SecurePass123!"
        }')
    
    if echo "$REGISTER_RESPONSE" | grep -q "회원가입이 완료"; then
        log_success "✅ 회원가입 API 테스트 통과"
    else
        log_error "❌ 회원가입 API 테스트 실패"
        echo "응답: $REGISTER_RESPONSE"
    fi
    
    # 로그인 API 테스트
    LOGIN_RESPONSE=$(curl -s -X POST http://localhost:3000/api/auth/login \
        -H "Content-Type: application/json" \
        -d '{
            "email": "test@example.com",
            "password": "SecurePass123!"
        }')
    
    if echo "$LOGIN_RESPONSE" | grep -q "로그인이 완료"; then
        log_success "✅ 로그인 API 테스트 통과"
    else
        log_error "❌ 로그인 API 테스트 실패"
        echo "응답: $LOGIN_RESPONSE"
    fi
    
    # Jest 테스트 실행
    log_info "Jest 테스트를 실행하는 중..."
    if npm test --silent; then
        log_success "✅ Jest 테스트 통과"
    else
        log_warning "⚠️  Jest 테스트에서 일부 오류가 발생했습니다."
    fi
    
    # 서버 종료
    kill $SERVER_PID 2>/dev/null || true
    sleep 2
    
    log_success "모든 테스트가 완료되었습니다!"
}

# 결과 요약
show_summary() {
    log_info "=== Kiro 설치 및 테스트 완료 ==="
    echo ""
    echo "📁 테스트 프로젝트 위치: $HOME/kiro-test-project"
    echo "⚙️  설정 파일: ~/.kiro/settings.json"
    echo "🔧 Aliases 파일: ~/.kiro_aliases"
    echo ""
    echo "🚀 다음 단계:"
    echo "1. 새 터미널을 열어서 aliases를 로드하세요."
    echo "2. cd ~/kiro-test-project"
    echo "3. kiro-start 명령어로 서버를 실행하세요."
    echo "4. http://localhost:3000에서 API를 테스트하세요."
    echo ""
    echo "📚 학습 자료:"
    echo "- specs/user-auth/ 디렉토리의 Spec 파일들을 살펴보세요."
    echo "- hooks/ 디렉토리의 자동화 스크립트들을 확인하세요."
    echo "- src/ 디렉토리의 샘플 코드를 분석해보세요."
    echo ""
    echo "🎯 추가 실습:"
    echo "- 새로운 기능의 Spec을 작성해보세요."
    echo "- Hook을 수정하여 자동화 기능을 개선해보세요."
    echo "- 실제 Kiro 출시 시 이 경험을 바탕으로 빠르게 적응하세요!"
    echo ""
    log_success "Kiro AI IDE 체험을 위한 모든 준비가 완료되었습니다! 🎉"
}

# 메인 실행 함수
main() {
    echo "🚀 Kiro AI IDE 설치 및 테스트 스크립트"
    echo "========================================"
    echo ""
    
    check_system_requirements
    install_kiro
    create_test_project
    create_spec_files
    create_hook_files
    create_sample_code
    setup_aliases
    run_tests
    show_summary
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 