#!/bin/bash

# Unregistry alias 설정 스크립트
# ~/.zshrc에 Unregistry 관련 유용한 alias와 함수들을 추가합니다.

echo "🔧 Unregistry zshrc alias 설정 중..."

# 백업 생성
if [ -f ~/.zshrc ]; then
    cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ 기존 ~/.zshrc 백업 완료"
fi

# Unregistry alias 추가
cat >> ~/.zshrc << 'EOF'

# ========================================
# Unregistry 관련 설정
# ========================================

# 환경 변수
export UNREGISTRY_DEFAULT_SERVER="deploy-server"
export DOCKER_APP_NAME="myapp"

# 기본 alias
alias pussh="docker pussh"
alias dpush="docker pussh"

# 배포 관련 alias
alias deploy-dev="docker pussh \$DOCKER_APP_NAME:latest dev-server"
alias deploy-staging="docker pussh \$DOCKER_APP_NAME:latest staging-server"
alias deploy-prod="docker pussh \$DOCKER_APP_NAME:latest prod-server"

# 서버 상태 확인
alias dev-status="ssh \$UNREGISTRY_DEFAULT_SERVER docker ps"
alias dev-logs="ssh \$UNREGISTRY_DEFAULT_SERVER docker logs -f \$DOCKER_APP_NAME"
alias dev-images="ssh \$UNREGISTRY_DEFAULT_SERVER docker images"

# 정리 작업
alias clean-dev="ssh \$UNREGISTRY_DEFAULT_SERVER docker image prune -f"
alias clean-containers="ssh \$UNREGISTRY_DEFAULT_SERVER docker container prune -f"
alias clean-all="ssh \$UNREGISTRY_DEFAULT_SERVER docker system prune -af"

# Docker 빌드 + 배포 함수
quick_deploy() {
    local tag=${1:-latest}
    local server=${2:-$UNREGISTRY_DEFAULT_SERVER}
    local app=${3:-$DOCKER_APP_NAME}
    
    echo "🏗️  Building $app:$tag..."
    docker build -t $app:$tag .
    
    echo "🚀 Deploying to $server..."
    docker pussh $app:$tag $server
    
    echo "✅ Deployment complete!"
}

# 버전 태그 자동 생성 + 배포
deploy_with_timestamp() {
    local server=${1:-$UNREGISTRY_DEFAULT_SERVER}
    local app=${2:-$DOCKER_APP_NAME}
    local tag="${app}:$(date +%Y%m%d-%H%M%S)"
    
    echo "🏗️  Building $tag..."
    docker build -t $tag .
    
    echo "🚀 Deploying to $server..."
    docker pussh $tag $server
    
    echo "✅ Deployed: $tag"
}

# 멀티 서버 배포
deploy_multi() {
    local image=$1
    shift
    local servers=("$@")
    
    if [ -z "$image" ] || [ ${#servers[@]} -eq 0 ]; then
        echo "사용법: deploy_multi <image:tag> <server1> <server2> ..."
        return 1
    fi
    
    echo "🚀 Multi-server deployment starting..."
    for server in "${servers[@]}"; do
        echo "  Deploying to $server..."
        docker pussh "$image" "$server" &
    done
    
    wait
    echo "✅ All deployments completed!"
}

# 배포 상태 확인
check_deployment() {
    local image=$1
    local server=${2:-$UNREGISTRY_DEFAULT_SERVER}
    
    if [ -z "$image" ]; then
        echo "사용법: check_deployment <image:tag> [server]"
        return 1
    fi
    
    echo "📊 Checking deployment status on $server..."
    ssh $server "docker images | grep '$image' && docker ps | grep '$image'"
}

# 롤백 함수
rollback() {
    local server=${1:-$UNREGISTRY_DEFAULT_SERVER}
    local app=${2:-$DOCKER_APP_NAME}
    
    echo "🔄 Rolling back on $server..."
    ssh $server "
        # 현재 실행 중인 컨테이너 확인
        current=\$(docker ps --filter name=$app --format '{{.Image}}')
        echo 'Current image: \$current'
        
        # 이전 이미지 찾기
        previous=\$(docker images $app --format '{{.Repository}}:{{.Tag}}' | head -2 | tail -1)
        echo 'Previous image: \$previous'
        
        if [ ! -z \"\$previous\" ] && [ \"\$previous\" != \"\$current\" ]; then
            docker stop $app || true
            docker rm $app || true
            docker run -d --name $app -p 3000:3000 \$previous
            echo '✅ Rollback completed to: \$previous'
        else
            echo '❌ No previous version found'
        fi
    "
}

# 테스트 환경 관리
alias test-unregistry="./scripts/test-unregistry.sh"
alias setup-test="./scripts/test-unregistry.sh --setup"
alias run-test="./scripts/test-unregistry.sh --test"
alias benchmark-test="./scripts/test-unregistry.sh --benchmark"
alias cleanup-test="./scripts/test-unregistry.sh --cleanup"

# Docker 관련 편의 함수
dps() {
    # 로컬과 원격 서버의 컨테이너 상태를 함께 보기
    echo "=== Local Docker Containers ==="
    docker ps
    echo ""
    echo "=== Remote Server Containers ==="
    ssh ${1:-$UNREGISTRY_DEFAULT_SERVER} docker ps
}

dimages() {
    # 로컬과 원격 서버의 이미지를 함께 보기
    echo "=== Local Docker Images ==="
    docker images
    echo ""
    echo "=== Remote Server Images ==="
    ssh ${1:-$UNREGISTRY_DEFAULT_SERVER} docker images
}

# 성능 모니터링
monitor_deployment() {
    local server=${1:-$UNREGISTRY_DEFAULT_SERVER}
    
    echo "📊 Deployment monitoring for $server"
    echo "========================================="
    
    ssh $server "
        echo '=== System Info ==='
        uname -a
        echo ''
        
        echo '=== Disk Usage ==='
        df -h | grep -E '(Filesystem|/var/lib/docker|/$)'
        echo ''
        
        echo '=== Memory Usage ==='
        free -h
        echo ''
        
        echo '=== Docker Info ==='
        docker system df
        echo ''
        
        echo '=== Running Containers ==='
        docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
    "
}

# 로그 모니터링
tail_logs() {
    local container=${1:-$DOCKER_APP_NAME}
    local server=${2:-$UNREGISTRY_DEFAULT_SERVER}
    
    echo "📜 Tailing logs for $container on $server..."
    ssh $server docker logs -f $container
}

echo "✅ Unregistry aliases loaded!"
echo ""
echo "주요 명령어:"
echo "  pussh <image> <server>    - 이미지 배포"
echo "  quick_deploy [tag] [server] - 빌드 + 배포"
echo "  deploy_with_timestamp [server] - 타임스탬프 태그로 배포"
echo "  deploy_multi <image> <server1> <server2> ... - 멀티 서버 배포"
echo "  rollback [server]         - 이전 버전으로 롤백"
echo "  monitor_deployment [server] - 서버 상태 모니터링"
echo ""

EOF

echo "✅ ~/.zshrc에 Unregistry alias 추가 완료!"
echo ""
echo "설정을 적용하려면 다음을 실행하세요:"
echo "  source ~/.zshrc"
echo ""
echo "또는 새 터미널을 열어주세요." 