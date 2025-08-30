#!/bin/bash
# firecracker-install.sh

set -e

echo "🔥 Firecracker MicroVM 자동 설치 스크립트"

# 변수 설정
FIRECRACKER_VERSION="v1.12.1"
ARCH="$(uname -m)"
INSTALL_DIR="/usr/local/bin"

# 시스템 요구사항 확인
check_requirements() {
    echo "📋 시스템 요구사항 확인 중..."
    
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        echo "❌ 이 스크립트는 Linux에서만 실행됩니다."
        exit 1
    fi
    
    if ! command -v curl &> /dev/null; then
        echo "📦 curl 설치 중..."
        sudo apt update && sudo apt install -y curl
    fi
    
    echo "✅ 요구사항 확인 완료"
}

# KVM 지원 확인
check_kvm() {
    echo "🔍 KVM 지원 확인 중..."
    
    if [[ ! -e /dev/kvm ]]; then
        echo "❌ KVM이 활성화되지 않았습니다."
        echo "BIOS에서 가상화 기능을 활성화하고 다시 시도하세요."
        exit 1
    fi
    
    if ! groups | grep -q kvm; then
        echo "📝 사용자를 KVM 그룹에 추가 중..."
        sudo usermod -a -G kvm $USER
        echo "⚠️  변경사항 적용을 위해 로그아웃 후 다시 로그인하세요."
    fi
    
    echo "✅ KVM 지원 확인됨"
}

# Firecracker 다운로드 및 설치
install_firecracker() {
    echo "📥 Firecracker ${FIRECRACKER_VERSION} 다운로드 중..."
    
    cd /tmp
    curl -LOJ "https://github.com/firecracker-microvm/firecracker/releases/download/${FIRECRACKER_VERSION}/firecracker-${FIRECRACKER_VERSION}-${ARCH}.tgz"
    
    echo "📦 압축 해제 중..."
    tar -xzf "firecracker-${FIRECRACKER_VERSION}-${ARCH}.tgz"
    
    echo "🔧 바이너리 설치 중..."
    sudo mv "release-${FIRECRACKER_VERSION}-${ARCH}/firecracker-${FIRECRACKER_VERSION}-${ARCH}" "${INSTALL_DIR}/firecracker"
    sudo mv "release-${FIRECRACKER_VERSION}-${ARCH}/jailer-${FIRECRACKER_VERSION}-${ARCH}" "${INSTALL_DIR}/jailer"
    sudo chmod +x "${INSTALL_DIR}/firecracker" "${INSTALL_DIR}/jailer"
    
    echo "🧹 임시 파일 정리..."
    rm -rf /tmp/firecracker-${FIRECRACKER_VERSION}-${ARCH}.tgz /tmp/release-${FIRECRACKER_VERSION}-${ARCH}
    
    echo "✅ 설치 완료!"
}

# 설치 확인
verify_installation() {
    echo "🔍 설치 검증 중..."
    
    if firecracker --version &> /dev/null; then
        echo "✅ Firecracker 설치 성공: $(firecracker --version)"
    else
        echo "❌ Firecracker 설치 실패"
        exit 1
    fi
    
    if jailer --version &> /dev/null; then
        echo "✅ Jailer 설치 성공: $(jailer --version)"
    else
        echo "❌ Jailer 설치 실패"
        exit 1
    fi
}

# 메인 실행
main() {
    check_requirements
    check_kvm
    install_firecracker
    verify_installation
    
    echo ""
    echo "🎉 Firecracker MicroVM 설치가 완료되었습니다!"
    echo "📖 사용법: firecracker --help"
    echo "🔗 문서: https://github.com/firecracker-microvm/firecracker/tree/main/docs"
}

main "$@" 