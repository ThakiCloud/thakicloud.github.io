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
pip install numpy==1.24.3 pandas==2.0.3 scipy==1.11.1 -q

# 시계열 특화 라이브러리
echo "  📈 시계열 분석 라이브러리 설치..."
pip install statsmodels==0.14.0 -q

# 머신러닝 라이브러리
echo "  🤖 머신러닝 라이브러리 설치..."
pip install scikit-learn==1.3.0 -q

echo "✅ 패키지 설치 확인:"
pip list | grep -E "(numpy|pandas|scipy|scikit-learn|statsmodels)"

# 디렉토리 구조 생성
echo "📁 프로젝트 디렉토리 생성..."
mkdir -p {data,models,scripts,results}

echo "✅ 헤지펀드 모델링 환경 설정 완료!"
echo "�� 프로젝트 구조:"
ls -la 