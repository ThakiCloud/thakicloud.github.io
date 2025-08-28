#!/bin/bash

# Unregistry 테스트 스크립트
# macOS에서 Docker in Docker를 사용한 테스트 환경 구성

set -e

echo "🚀 Unregistry 테스트 환경 설정 중..."

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 함수 정의
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 사전 요구사항 확인
check_requirements() {
    log_info "사전 요구사항 확인 중..."
    
    # Docker 확인
    if ! command -v docker &> /dev/null; then
        log_error "Docker가 설치되어 있지 않습니다."
        exit 1
    fi
    
    # Docker가 실행 중인지 확인
    if ! docker info &> /dev/null; then
        log_error "Docker가 실행되고 있지 않습니다. Docker Desktop을 시작해주세요."
        exit 1
    fi
    
    log_info "✅ Docker: $(docker --version)"
}

# Unregistry 설치
install_unregistry() {
    log_info "Unregistry(docker-pussh) 설치 중..."
    
    # 이미 설치된 경우 건너뛰기
    if command -v docker-pussh &> /dev/null; then
        log_info "✅ docker-pussh가 이미 설치되어 있습니다."
        return
    fi
    
    # Homebrew 확인
    if command -v brew &> /dev/null; then
        log_info "Homebrew를 통해 설치합니다..."
        brew install psviderski/tap/docker-pussh
        
        # Docker CLI 플러그인 설정
        mkdir -p ~/.docker/cli-plugins
        ln -sf "$(brew --prefix)/bin/docker-pussh" ~/.docker/cli-plugins/docker-pussh
    else
        log_info "직접 다운로드합니다..."
        mkdir -p ~/.docker/cli-plugins
        curl -sSL https://raw.githubusercontent.com/psviderski/unregistry/v0.1.0/docker-pussh \
          -o ~/.docker/cli-plugins/docker-pussh
        chmod +x ~/.docker/cli-plugins/docker-pussh
    fi
    
    log_info "✅ Unregistry 설치 완료"
}

# 테스트 서버 설정 (Docker in Docker)
setup_test_server() {
    log_info "테스트 서버 설정 중..."
    
    # 기존 테스트 서버 정리
    docker rm -f unregistry-test-server 2>/dev/null || true
    
    # SSH 키 생성 (이미 있는 경우 건너뛰기)
    if [ ! -f ~/.ssh/unregistry_test_key ]; then
        log_info "SSH 키 생성 중..."
        ssh-keygen -t ed25519 -f ~/.ssh/unregistry_test_key -N "" -C "unregistry-test"
    fi
    
    # Docker in Docker 컨테이너 시작 (SSH 포함)
    log_info "Docker in Docker 컨테이너 시작 중..."
    docker run -d \
        --name unregistry-test-server \
        --privileged \
        -p 2222:22 \
        -v /var/lib/docker \
        --add-host host.docker.internal:host-gateway \
        linuxserver/openssh-server:latest
    
    # 컨테이너가 시작될 때까지 대기
    log_info "컨테이너 시작 대기 중..."
    sleep 10
    
    # SSH 설정
    docker exec unregistry-test-server sh -c "
        # Docker 설치
        apk add --no-cache docker docker-compose curl
        
        # Docker 서비스 시작
        service docker start
        
        # SSH 키 설정
        mkdir -p /root/.ssh
        chmod 700 /root/.ssh
    "
    
    # 공개키 복사
    docker cp ~/.ssh/unregistry_test_key.pub unregistry-test-server:/root/.ssh/authorized_keys
    docker exec unregistry-test-server chmod 600 /root/.ssh/authorized_keys
    
    log_info "✅ 테스트 서버 설정 완료"
}

# SSH 연결 테스트
test_ssh_connection() {
    log_info "SSH 연결 테스트 중..."
    
    # SSH 설정 파일 업데이트
    cat >> ~/.ssh/config << EOF

# Unregistry 테스트 설정
Host unregistry-test
    HostName localhost
    Port 2222
    User root
    IdentityFile ~/.ssh/unregistry_test_key
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
    
    # SSH 연결 테스트
    for i in {1..5}; do
        if ssh unregistry-test "echo 'SSH 연결 성공'" 2>/dev/null; then
            log_info "✅ SSH 연결 테스트 성공"
            return
        fi
        log_warn "SSH 연결 시도 $i/5 실패, 5초 후 재시도..."
        sleep 5
    done
    
    log_error "SSH 연결 실패"
    exit 1
}

# Docker 환경 설정
setup_docker_environment() {
    log_info "Docker 환경 설정 중..."
    
    # 테스트 서버에서 Docker 설정
    ssh unregistry-test "
        # Docker 서비스 확인
        service docker status || service docker start
        
        # Docker 작동 확인
        docker --version
        docker info
        
        # Unregistry 이미지 미리 다운로드
        docker pull ghcr.io/psviderski/unregistry:latest
    "
    
    log_info "✅ Docker 환경 설정 완료"
}

# 테스트 이미지 생성
create_test_image() {
    log_info "테스트 이미지 생성 중..."
    
    # 임시 디렉토리 생성
    TEST_DIR="/tmp/unregistry-test"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # 간단한 웹 앱 생성
    cat > index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Unregistry Test</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
        .container { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                    color: white; padding: 50px; border-radius: 10px; 
                    display: inline-block; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Unregistry 테스트 성공!</h1>
        <p>SSH를 통한 Docker 이미지 직접 배포가 완료되었습니다.</p>
        <p>시간: $(date)</p>
    </div>
</body>
</html>
EOF
    
    # Dockerfile 생성
    cat > Dockerfile << EOF
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF
    
    # 이미지 빌드
    docker build -t unregistry-test-app:v1.0.0 .
    
    log_info "✅ 테스트 이미지 생성 완료: unregistry-test-app:v1.0.0"
}

# Unregistry 테스트 실행
run_unregistry_test() {
    log_info "Unregistry를 사용하여 이미지 배포 중..."
    
    # 배포 시간 측정 시작
    start_time=$(date +%s)
    
    # Docker pussh 실행
    if docker pussh unregistry-test-app:v1.0.0 unregistry-test; then
        # 배포 시간 계산
        end_time=$(date +%s)
        deploy_time=$((end_time - start_time))
        
        log_info "✅ 이미지 배포 성공! (소요 시간: ${deploy_time}초)"
        
        # 원격 서버에서 이미지 확인
        log_info "원격 서버에서 이미지 확인 중..."
        ssh unregistry-test "docker images | grep unregistry-test-app"
        
        # 컨테이너 실행 테스트
        log_info "배포된 이미지로 컨테이너 실행 중..."
        ssh unregistry-test "
            docker stop test-container 2>/dev/null || true
            docker rm test-container 2>/dev/null || true
            docker run -d --name test-container -p 8080:80 unregistry-test-app:v1.0.0
        "
        
        # 웹 서비스 확인
        log_info "웹 서비스 테스트 중..."
        sleep 3
        if ssh unregistry-test "curl -s http://localhost:8080" | grep -q "Unregistry 테스트 성공"; then
            log_info "✅ 웹 서비스 테스트 성공!"
        else
            log_warn "웹 서비스 테스트 실패"
        fi
        
    else
        log_error "이미지 배포 실패"
        return 1
    fi
}

# 성능 비교 테스트
performance_comparison() {
    log_info "성능 비교 테스트 실행 중..."
    
    # 더 큰 이미지 생성 (Node.js 앱)
    cd /tmp/unregistry-test
    
    cat > package.json << EOF
{
  "name": "unregistry-benchmark",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.0",
    "lodash": "^4.17.21"
  }
}
EOF
    
    cat > server.js << EOF
const express = require('express');
const _ = require('lodash');
const app = express();

app.get('/', (req, res) => {
    res.json({
        message: 'Unregistry 성능 테스트',
        timestamp: new Date().toISOString(),
        data: _.range(1000).map(i => ({ id: i, value: Math.random() }))
    });
});

app.listen(3000, () => {
    console.log('Server running on port 3000');
});
EOF
    
    cat > Dockerfile.bench << EOF
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
EOF
    
    # 벤치마크 이미지 빌드
    docker build -f Dockerfile.bench -t unregistry-benchmark:latest .
    
    # Unregistry 배포 시간 측정
    log_info "Unregistry 배포 성능 측정 중..."
    start_time=$(date +%s)
    docker pussh unregistry-benchmark:latest unregistry-test
    end_time=$(date +%s)
    unregistry_time=$((end_time - start_time))
    
    log_info "📊 성능 측정 결과:"
    log_info "  - Unregistry 배포 시간: ${unregistry_time}초"
    log_info "  - 일반적인 Docker Hub 푸시: 60-180초 (네트워크에 따라)"
    log_info "  - 예상 시간 절약: $(( (120 - unregistry_time) * 100 / 120 ))%"
}

# 정리 작업
cleanup() {
    log_info "테스트 환경 정리 중..."
    
    # 테스트 컨테이너 중지 및 제거
    docker rm -f unregistry-test-server 2>/dev/null || true
    
    # 테스트 이미지 제거
    docker rmi unregistry-test-app:v1.0.0 2>/dev/null || true
    docker rmi unregistry-benchmark:latest 2>/dev/null || true
    
    # SSH 설정 정리 (선택사항)
    if [ "$1" == "--clean-ssh" ]; then
        rm -f ~/.ssh/unregistry_test_key*
        # SSH config에서 테스트 설정 제거
        sed -i '' '/# Unregistry 테스트 설정/,/UserKnownHostsFile \/dev\/null/d' ~/.ssh/config 2>/dev/null || true
    fi
    
    # 임시 파일 정리
    rm -rf /tmp/unregistry-test
    
    log_info "✅ 정리 완료"
}

# 도움말 출력
show_help() {
    echo "Unregistry 테스트 스크립트"
    echo ""
    echo "사용법: $0 [옵션]"
    echo ""
    echo "옵션:"
    echo "  --setup     : 테스트 환경만 설정"
    echo "  --test      : 기본 테스트만 실행"
    echo "  --benchmark : 성능 테스트만 실행"
    echo "  --cleanup   : 테스트 환경 정리"
    echo "  --help      : 이 도움말 출력"
    echo ""
    echo "기본 실행: 전체 테스트 수행"
}

# 메인 함수
main() {
    case "$1" in
        --setup)
            check_requirements
            install_unregistry
            setup_test_server
            test_ssh_connection
            setup_docker_environment
            ;;
        --test)
            create_test_image
            run_unregistry_test
            ;;
        --benchmark)
            performance_comparison
            ;;
        --cleanup)
            cleanup "$2"
            ;;
        --help)
            show_help
            ;;
        *)
            log_info "🚀 Unregistry 전체 테스트 시작"
            check_requirements
            install_unregistry
            setup_test_server
            test_ssh_connection
            setup_docker_environment
            create_test_image
            run_unregistry_test
            performance_comparison
            
            log_info "🎉 모든 테스트 완료!"
            log_info ""
            log_info "정리하려면: $0 --cleanup"
            log_info "SSH 설정까지 정리하려면: $0 --cleanup --clean-ssh"
            ;;
    esac
}

# 스크립트 실행
main "$@" 