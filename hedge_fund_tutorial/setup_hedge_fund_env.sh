#!/bin/bash
# setup_hedge_fund_env.sh

echo "🏦 헤지펀드 시계열 모델링 환경 설정"
echo "📍 작업 디렉토리: $(pwd)"
echo "🖥️  시스템: $(uname -s) $(uname -r)"

# macOS 전용 시스템 정보
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "💻 CPU: $(sysctl -n machdep.cpu.brand_string)"
    echo "🧠 코어 수: $(sysctl -n hw.ncpu)"
    echo "💾 메모리: $(echo "$(sysctl -n hw.memsize) / 1024 / 1024 / 1024" | bc) GB"
fi

echo "🐍 Python 버전: $(python3 --version)"

# 가상환경 생성
echo "🔧 가상환경 생성 중..."
python3 -m venv hedge_fund_env
source hedge_fund_env/bin/activate

# 필수 패키지 설치
echo "📦 필수 패키지 설치 중..."
pip install --upgrade pip -q

# 기본 라이브러리
echo "  📊 기본 데이터 라이브러리 설치..."
pip install numpy pandas scipy -q

echo "✅ 패키지 설치 확인:"
pip list | grep -E "(numpy|pandas|scipy)"

# 디렉토리 구조 생성
echo "📁 프로젝트 디렉토리 생성..."
mkdir -p {data,models,scripts,results}

echo "✅ 헤지펀드 모델링 환경 설정 완료!"
echo "📁 프로젝트 구조:"
ls -la
