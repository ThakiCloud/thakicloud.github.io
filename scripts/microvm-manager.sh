#!/bin/bash
# microvm-manager.sh

SOCKET_PATH="/tmp/firecracker.socket"
VM_NAME="${1:-demo-vm}"
ACTION="${2:-start}"

start_vm() {
    echo "🚀 MicroVM '$VM_NAME' 시작 중..."
    
    # 기존 소켓 정리
    rm -f "$SOCKET_PATH"
    
    # Firecracker 시작
    firecracker --api-sock "$SOCKET_PATH" &
    FIRECRACKER_PID=$!
    
    sleep 2
    
    echo "✅ MicroVM이 시작되었습니다. PID: $FIRECRACKER_PID"
    echo "🔌 API 소켓: $SOCKET_PATH"
}

stop_vm() {
    echo "🛑 MicroVM '$VM_NAME' 중지 중..."
    
    if [[ -S "$SOCKET_PATH" ]]; then
        curl --unix-socket "$SOCKET_PATH" -X PUT 'http://localhost/actions' \
            -H 'Content-Type: application/json' \
            -d '{"action_type": "SendCtrlAltDel"}' &> /dev/null
        
        sleep 5
        rm -f "$SOCKET_PATH"
        echo "✅ MicroVM이 중지되었습니다."
    else
        echo "❌ 실행 중인 MicroVM을 찾을 수 없습니다."
    fi
}

status_vm() {
    if [[ -S "$SOCKET_PATH" ]]; then
        echo "✅ MicroVM '$VM_NAME'이 실행 중입니다."
        
        # 인스턴스 정보 조회
        curl --unix-socket "$SOCKET_PATH" -s 'http://localhost/machine-config' | jq 2>/dev/null || echo "API 응답 없음"
    else
        echo "❌ MicroVM '$VM_NAME'이 실행되지 않습니다."
    fi
}

case "$ACTION" in
    start)
        start_vm
        ;;
    stop)
        stop_vm
        ;;
    status)
        status_vm
        ;;
    restart)
        stop_vm
        sleep 2
        start_vm
        ;;
    *)
        echo "사용법: $0 [vm-name] [start|stop|status|restart]"
        exit 1
        ;;
esac 