#!/bin/bash

# OpenReplay 데모 환경 설정 스크립트
# macOS/Linux용

set -e  # 오류 발생 시 스크립트 중단

echo "🚀 OpenReplay 데모 환경 설정을 시작합니다..."

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 현재 디렉토리 저장
DEMO_DIR=$(pwd)
OPENREPLAY_DIR="$HOME/openreplay-server"

echo -e "${BLUE}📁 작업 디렉토리: $DEMO_DIR${NC}"

# 시스템 요구사항 확인
echo -e "${YELLOW}🔍 시스템 요구사항 확인 중...${NC}"

# Node.js 확인
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js가 설치되어 있지 않습니다.${NC}"
    echo -e "${YELLOW}💡 설치 방법:${NC}"
    echo "   macOS: brew install node"
    echo "   Ubuntu: sudo apt install nodejs npm"
    exit 1
fi

NODE_VERSION=$(node --version)
echo -e "${GREEN}✅ Node.js: $NODE_VERSION${NC}"

# npm 확인
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm이 설치되어 있지 않습니다.${NC}"
    exit 1
fi

NPM_VERSION=$(npm --version)
echo -e "${GREEN}✅ npm: $NPM_VERSION${NC}"

# Docker 확인
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker가 설치되어 있지 않습니다.${NC}"
    echo -e "${YELLOW}💡 설치 방법:${NC}"
    echo "   macOS: brew install --cask docker"
    echo "   Ubuntu: sudo apt install docker.io"
    exit 1
fi

DOCKER_VERSION=$(docker --version)
echo -e "${GREEN}✅ Docker: $DOCKER_VERSION${NC}"

# Docker Compose 확인
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose가 설치되어 있지 않습니다.${NC}"
    echo -e "${YELLOW}💡 설치 방법:${NC}"
    echo "   macOS: brew install docker-compose"
    echo "   Ubuntu: sudo apt install docker-compose"
    exit 1
fi

COMPOSE_VERSION=$(docker-compose --version)
echo -e "${GREEN}✅ Docker Compose: $COMPOSE_VERSION${NC}"

# Git 확인
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git이 설치되어 있지 않습니다.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Git: $(git --version)${NC}"

# OpenReplay 서버 설정
echo -e "${YELLOW}📦 OpenReplay 서버 설정 중...${NC}"

if [ ! -d "$OPENREPLAY_DIR" ]; then
    echo "📥 OpenReplay 저장소 클론 중..."
    git clone https://github.com/openreplay/openreplay.git "$OPENREPLAY_DIR"
else
    echo "📂 OpenReplay 저장소가 이미 존재합니다."
    cd "$OPENREPLAY_DIR"
    echo "🔄 최신 버전으로 업데이트 중..."
    git pull origin main || echo "⚠️ 업데이트 실패 (계속 진행)"
fi

# Docker Compose 설정
cd "$OPENREPLAY_DIR/scripts/docker-compose"

if [ ! -f ".env" ]; then
    echo "🔧 환경 변수 파일 생성 중..."
    cp .env.example .env
    
    # 기본 설정 값 적용
    sed -i.bak 's/DOMAIN_NAME=.*/DOMAIN_NAME=localhost/' .env
    sed -i.bak 's/POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=openreplay_demo_pass/' .env
    sed -i.bak 's/JWT_SECRET=.*/JWT_SECRET=your_jwt_secret_key_for_demo/' .env
    
    echo -e "${GREEN}✅ 환경 변수 파일이 생성되었습니다.${NC}"
else
    echo "📝 환경 변수 파일이 이미 존재합니다."
fi

# 데모 앱 의존성 설치
echo -e "${YELLOW}📦 데모 앱 의존성 설치 중...${NC}"
cd "$DEMO_DIR"

if [ ! -d "node_modules" ]; then
    echo "📥 npm 패키지 설치 중..."
    npm install
else
    echo "📂 node_modules가 이미 존재합니다."
fi

# 환경 변수 파일 생성
if [ ! -f ".env" ]; then
    echo "🔧 데모 앱 환경 변수 파일 생성 중..."
    cat > .env << EOF
# OpenReplay 데모 설정
OPENREPLAY_PROJECT_KEY=demo_project_key
OPENREPLAY_INGEST_POINT=http://localhost:9000/ingest
DEMO_MODE=true
DEBUG_MODE=true

# 서버 설정
PORT=3000
NODE_ENV=development
EOF
    echo -e "${GREEN}✅ 데모 환경 변수 파일이 생성되었습니다.${NC}"
fi

# 실행 스크립트 생성
echo -e "${YELLOW}📝 실행 스크립트 생성 중...${NC}"

cat > start-full-demo.sh << 'EOF'
#!/bin/bash

echo "🚀 OpenReplay 전체 데모 시작..."

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

OPENREPLAY_DIR="$HOME/openreplay-server"

# OpenReplay 서버 시작
echo -e "${YELLOW}🔧 OpenReplay 서버 시작 중...${NC}"
cd "$OPENREPLAY_DIR/scripts/docker-compose"

# 이전 컨테이너 정리
docker-compose down 2>/dev/null || true

# 서버 시작
docker-compose up -d

echo -e "${YELLOW}⏳ OpenReplay 서버 초기화 대기 중 (60초)...${NC}"
echo "   데이터베이스와 서비스들이 준비되는 시간입니다."

# 서비스 상태 확인
for i in {1..12}; do
    sleep 5
    echo -n "."
    
    # 서비스 상태 확인
    if docker-compose ps | grep -q "Up"; then
        if [ $i -ge 8 ]; then
            break
        fi
    fi
done
echo ""

# 서비스 상태 출력
echo -e "${YELLOW}📊 서비스 상태:${NC}"
docker-compose ps

# 데모 앱 시작
echo -e "${YELLOW}🌐 데모 앱 시작 중...${NC}"
cd "$OLDPWD"

echo -e "${GREEN}✅ 설정 완료!${NC}"
echo ""
echo -e "${YELLOW}📱 접속 정보:${NC}"
echo "   🎮 데모 앱:        http://localhost:3000"
echo "   🎯 OpenReplay:     http://localhost:9000"
echo "   📊 MinIO Console:  http://localhost:9001"
echo "   🗄️ DB Admin:       http://localhost:8080"
echo ""
echo -e "${YELLOW}💡 사용법:${NC}"
echo "   1. 브라우저에서 http://localhost:3000 열기"
echo "   2. 다양한 기능 테스트하기"
echo "   3. http://localhost:9000 에서 세션 확인하기"
echo ""
echo "🔄 데모 앱을 시작합니다..."

# 데모 앱 실행
npm start
EOF

cat > stop-demo.sh << 'EOF'
#!/bin/bash

echo "🛑 OpenReplay 데모 정리 중..."

OPENREPLAY_DIR="$HOME/openreplay-server"

# 데모 앱 프로세스 종료 (포트 3000 사용하는 프로세스)
echo "📱 데모 앱 중지 중..."
lsof -ti:3000 | xargs kill -9 2>/dev/null || true

# OpenReplay 서버 중지
echo "🔧 OpenReplay 서버 중지 중..."
cd "$OPENREPLAY_DIR/scripts/docker-compose"
docker-compose down

echo "✅ 데모 정리 완료!"
echo ""
echo "💡 다시 시작하려면: ./start-full-demo.sh"
EOF

# 실행 권한 부여
chmod +x start-full-demo.sh
chmod +x stop-demo.sh

# README 파일 생성
cat > README-DEMO.md << 'EOF'
# OpenReplay 데모 가이드

OpenReplay 세션 리플레이 플랫폼의 완전한 데모 환경입니다.

## 🚀 빠른 시작

```bash
# 전체 데모 시작 (서버 + 앱)
./start-full-demo.sh

# 데모 정리
./stop-demo.sh

# 데모 앱만 시작 (서버가 이미 실행중인 경우)
npm start
```

## 📱 접속 정보

- **데모 앱**: http://localhost:3000
- **OpenReplay 대시보드**: http://localhost:9000
- **MinIO Console**: http://localhost:9001 (minioadmin/minioadmin)
- **DB Admin**: http://localhost:8080

## 🎮 데모 기능

### 1. 기본 상호작용
- 카운터 증가/감소
- 버튼 클릭 추적

### 2. 폼 입력
- 텍스트 입력 추적
- 폼 제출 이벤트

### 3. API 호출
- 성공/실패 네트워크 요청
- 응답 시간 측정

### 4. 오류 처리
- JavaScript 오류 발생
- 콘솔 오류 생성
- 네트워크 오류 테스트

### 5. 성능 테스트
- CPU 집약적 작업
- 느린 작업 시뮬레이션

### 6. 프라이버시 제어
- 민감한 데이터 마스킹
- 입력 필드 보안

### 7. 사용자 경험
- 스크롤 추적
- 호버 이벤트
- 복잡한 상호작용

### 8. 분석 메트릭
- 전환 이벤트 추적
- 사용자 참여도 측정
- 기능 사용률 분석

## 🔧 문제 해결

### 서버가 시작되지 않는 경우
```bash
# Docker 프로세스 확인
docker ps

# 로그 확인
cd ~/openreplay-server/scripts/docker-compose
docker-compose logs
```

### 포트 충돌 문제
```bash
# 포트 사용 확인
lsof -i :3000  # 데모 앱
lsof -i :9000  # OpenReplay

# 프로세스 종료
kill -9 <PID>
```

### 브라우저 연결 문제
1. 브라우저 캐시 삭제
2. 개발자 도구에서 네트워크 탭 확인
3. `showDebugInfo()` 함수로 상태 확인

## 🛠️ 개발 모드

```bash
# 데모 앱만 개발 모드로 실행
npm run dev

# 서버 로그 실시간 확인
cd ~/openreplay-server/scripts/docker-compose
docker-compose logs -f
```

## 📊 모니터링

### 브라우저 콘솔에서 실행
```javascript
// 디버그 정보 표시
showDebugInfo();

// 트래커 상태 확인
console.log(tracker);

// 세션 토큰 확인
console.log(tracker.getSessionToken());
```

## 🔐 보안 설정

데모 환경에서는 보안 기능이 비활성화되어 있습니다:
- 입력 마스킹: 비활성화
- 텍스트 난독화: 비활성화

프로덕션에서는 반드시 활성화하세요!

## 📚 참고 자료

- [OpenReplay 공식 문서](https://docs.openreplay.com)
- [JavaScript SDK 가이드](https://docs.openreplay.com/sdk/js)
- [GitHub 저장소](https://github.com/openreplay/openreplay)
EOF

echo -e "${GREEN}✅ OpenReplay 데모 환경 설정이 완료되었습니다!${NC}"
echo ""
echo -e "${BLUE}🚀 다음 단계:${NC}"
echo "   1. ./start-full-demo.sh 실행"
echo "   2. http://localhost:3000 에서 데모 테스트"
echo "   3. http://localhost:9000 에서 세션 확인"
echo "   4. 완료 후 ./stop-demo.sh 실행"
echo ""
echo -e "${YELLOW}📖 자세한 사용법은 README-DEMO.md를 참조하세요.${NC}"
