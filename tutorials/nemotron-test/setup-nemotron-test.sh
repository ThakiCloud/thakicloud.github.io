#!/bin/bash

# NVIDIA Nemotron Nano 2 9B 테스트 환경 설정 스크립트
# macOS 환경에서 Thinking Budget 기능을 테스트하기 위한 설정

set -e

echo "🚀 NVIDIA Nemotron Nano 2 9B 테스트 환경 설정 시작..."

# 현재 디렉토리 확인
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📁 작업 디렉토리: $SCRIPT_DIR"

# Python 버전 확인
echo "🐍 Python 버전 확인 중..."
python3 --version

if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3가 설치되지 않았습니다."
    echo "💡 Homebrew로 설치하세요: brew install python3"
    exit 1
fi

# 가상환경 생성
echo "🏗️  가상환경 생성 중..."
if [ ! -d "nemotron-env" ]; then
    python3 -m venv nemotron-env
    echo "✅ 가상환경 생성 완료"
else
    echo "ℹ️  기존 가상환경 사용"
fi

# 가상환경 활성화
echo "🔄 가상환경 활성화 중..."
source nemotron-env/bin/activate

# 필수 패키지 설치
echo "📦 필수 패키지 설치 중..."
pip install --upgrade pip

# 패키지 설치 (macOS 최적화)
echo "⚡ vLLM 및 관련 패키지 설치 중..."
pip install vllm openai transformers torch torchvision torchaudio

# macOS Metal Performance Shaders 최적화
echo "🔧 macOS 최적화 설정 중..."
export PYTORCH_ENABLE_MPS_FALLBACK=1
export PYTORCH_MPS_HIGH_WATERMARK_RATIO=0.0

# 테스트 스크립트 실행 권한 부여
echo "🔐 스크립트 권한 설정 중..."
chmod +x thinking_budget_client.py

# 환경 확인
echo "🔍 설치된 패키지 확인 중..."
pip list | grep -E "(vllm|openai|transformers|torch)"

# vLLM 서버 시작 스크립트 생성
echo "📝 vLLM 서버 시작 스크립트 생성 중..."
cat > start-nemotron-server.sh << 'EOF'
#!/bin/bash
echo "🚀 NVIDIA Nemotron Nano 2 9B vLLM 서버 시작..."
echo "📋 모델: nvidia/NVIDIA-Nemotron-Nano-9B-v2"
echo "🌐 포트: 8000"
echo "⏹️  종료하려면 Ctrl+C를 누르세요"

# macOS 최적화 환경변수 설정
export PYTORCH_ENABLE_MPS_FALLBACK=1
export PYTORCH_MPS_HIGH_WATERMARK_RATIO=0.0

# vLLM 서버 시작
vllm serve nvidia/NVIDIA-Nemotron-Nano-9B-v2 \
    --trust-remote-code \
    --mamba_ssm_cache_dtype float32 \
    --port 8000 \
    --host 0.0.0.0 \
    --gpu_memory_utilization 0.8
EOF

chmod +x start-nemotron-server.sh

# 성능 모니터링 스크립트 생성
echo "📊 성능 모니터링 스크립트 생성 중..."
cat > monitor-nemotron.sh << 'EOF'
#!/bin/bash
echo "🔍 Nemotron Nano 2 성능 모니터링 시작..."

# GPU 사용률 (Metal 지원 Mac의 경우)
if command -v powermetrics &> /dev/null; then
    echo "⚡ GPU 사용률 확인 중..."
    sudo powermetrics --samplers gpu_power -n 1 -i 1000 | grep "GPU" || echo "GPU 정보 수집 실패"
fi

# 메모리 사용량
echo "💾 메모리 사용량:"
ps aux | grep vllm | head -5

# 디스크 사용량
echo "💿 디스크 사용량:"
df -h . | tail -1

# 네트워크 연결 확인
echo "🌐 vLLM 서버 연결 확인:"
curl -s http://localhost:8000/health 2>/dev/null && echo "✅ 서버 정상" || echo "❌ 서버 연결 실패"

echo "✅ 모니터링 완료"
EOF

chmod +x monitor-nemotron.sh

# 종합 테스트 스크립트 생성
echo "🧪 종합 테스트 스크립트 생성 중..."
cat > run-nemotron-tests.sh << 'EOF'
#!/bin/bash
echo "🧪 NVIDIA Nemotron Nano 2 9B 종합 테스트 실행..."

# 가상환경 활성화
source nemotron-env/bin/activate

# 서버 연결 확인
echo "🔗 서버 연결 상태 확인 중..."
if ! curl -s http://localhost:8000/health > /dev/null; then
    echo "❌ vLLM 서버가 실행되지 않았습니다."
    echo "💡 서버를 먼저 시작하세요: ./start-nemotron-server.sh"
    exit 1
fi

echo "✅ 서버 연결 확인 완료"

# 기본 테스트 실행
echo "📋 기본 테스트 실행 중..."
python3 thinking_budget_client.py --test basic

# 성능 비교 테스트 실행
echo "📊 성능 비교 테스트 실행 중..."
python3 thinking_budget_client.py --test comparison

echo "🎉 모든 테스트 완료!"
EOF

chmod +x run-nemotron-tests.sh

# README 파일 생성
echo "📖 README 파일 생성 중..."
cat > README.md << 'EOF'
# NVIDIA Nemotron Nano 2 9B 테스트 환경

macOS에서 NVIDIA Nemotron Nano 2 9B 모델의 Thinking Budget 기능을 테스트하기 위한 환경입니다.

## 🚀 빠른 시작

### 1. 환경 설정
```bash
./setup-nemotron-test.sh
```

### 2. 서버 시작
```bash
./start-nemotron-server.sh
```

### 3. 테스트 실행
새 터미널에서:
```bash
./run-nemotron-tests.sh
```

## 📁 파일 구조

- `setup-nemotron-test.sh`: 초기 환경 설정
- `start-nemotron-server.sh`: vLLM 서버 시작
- `thinking_budget_client.py`: Thinking Budget 클라이언트 구현
- `run-nemotron-tests.sh`: 종합 테스트 실행
- `monitor-nemotron.sh`: 성능 모니터링

## 🧠 Thinking Budget 테스트

다양한 복잡도의 작업에 대해 Thinking Budget을 조절하며 성능을 비교합니다:

- **64 토큰**: 간단한 질문 (빠른 응답)
- **128 토큰**: 기본적인 추론
- **256 토큰**: 중간 복잡도 작업
- **512 토큰**: 복잡한 추론
- **1024 토큰**: 매우 복잡한 문제

## 🔧 문제 해결

### 메모리 부족 오류
```bash
# GPU 메모리 사용률 조정
export PYTORCH_MPS_HIGH_WATERMARK_RATIO=0.0
```

### 서버 연결 실패
```bash
# 포트 사용 확인
lsof -i :8000
```

### 패키지 설치 오류
```bash
# 가상환경 재생성
rm -rf nemotron-env
python3 -m venv nemotron-env
source nemotron-env/bin/activate
pip install --upgrade pip
```

## 📊 성능 모니터링

실시간 성능 모니터링:
```bash
./monitor-nemotron.sh
```

## 🔗 참고 링크

- [NVIDIA Nemotron Nano 2 9B](https://huggingface.co/nvidia/NVIDIA-Nemotron-Nano-9B-v2)
- [vLLM 문서](https://docs.vllm.ai/)
- [Thinking Budget 가이드](https://huggingface.co/blog/nvidia/supercharge-ai-reasoning-with-nemotron-nano-2)
EOF

echo "✅ 환경 설정 완료!"
echo ""
echo "🎯 다음 단계:"
echo "1. 서버 시작: ./start-nemotron-server.sh"
echo "2. 새 터미널에서 테스트 실행: ./run-nemotron-tests.sh"
echo "3. 성능 모니터링: ./monitor-nemotron.sh"
echo ""
echo "📖 자세한 사용법: cat README.md"
