#!/bin/bash

# MetaGPT 테스트 환경 설정 스크립트
# 사용법: ./setup-test.sh

set -e

echo "🚀 MetaGPT 테스트 환경 설정 시작..."

# 현재 디렉토리 확인
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📁 작업 디렉토리: $SCRIPT_DIR"

# Python 버전 확인
echo "🐍 Python 버전 확인..."
python_version=$(python --version 2>&1 | cut -d' ' -f2)
echo "   Python 버전: $python_version"

major_version=$(echo $python_version | cut -d'.' -f1)
minor_version=$(echo $python_version | cut -d'.' -f2)

if [[ $major_version -eq 3 && $minor_version -ge 9 && $minor_version -lt 12 ]]; then
    echo "✅ Python 버전 호환 (3.9-3.11)"
else
    echo "❌ Python 버전 비호환: 3.9-3.11 필요"
    exit 1
fi

# 가상환경 생성 및 활성화
echo "🔧 가상환경 설정..."
if [[ ! -d "metagpt-test-env" ]]; then
    python -m venv metagpt-test-env
    echo "   가상환경 생성됨"
else
    echo "   기존 가상환경 사용"
fi

# 가상환경 활성화
source metagpt-test-env/bin/activate
echo "✅ 가상환경 활성화됨"

# pip 업그레이드
echo "📦 pip 업그레이드..."
pip install --upgrade pip

# MetaGPT 설치
echo "🤖 MetaGPT 설치 중..."
pip install --upgrade metagpt

# Node.js 및 pnpm 확인
echo "🌐 Node.js 환경 확인..."
if command -v node &> /dev/null; then
    node_version=$(node --version)
    echo "   Node.js: $node_version"
else
    echo "⚠️ Node.js가 설치되지 않았습니다"
    echo "   macOS: brew install node"
    echo "   Ubuntu: sudo apt-get install nodejs npm"
fi

if command -v pnpm &> /dev/null; then
    pnpm_version=$(pnpm --version)
    echo "   pnpm: v$pnpm_version"
else
    echo "📦 pnpm 설치 중..."
    npm install -g pnpm
fi

# MetaGPT 설정 초기화
echo "⚙️ MetaGPT 설정 초기화..."
if [[ ! -f "$HOME/.metagpt/config2.yaml" ]]; then
    echo "   설정 파일이 없습니다. 수동으로 설정해주세요:"
    echo "   metagpt --init-config"
    echo "   ~/.metagpt/config2.yaml 파일을 편집하여 API 키를 설정하세요"
else
    echo "✅ 기존 설정 파일 발견"
fi

# 테스트 스크립트 생성
echo "📝 테스트 스크립트 생성..."

# 설치 확인 스크립트
cat > test_installation.py << 'EOF'
import sys
import subprocess

def test_metagpt_installation():
    print("🔍 MetaGPT 설치 확인 중...")
    
    # Python 버전 확인
    python_version = sys.version_info
    print(f"✅ Python 버전: {python_version.major}.{python_version.minor}.{python_version.micro}")
    
    # MetaGPT 임포트 테스트
    try:
        import metagpt
        print(f"✅ MetaGPT 버전: {metagpt.__version__}")
    except ImportError as e:
        print(f"❌ MetaGPT 임포트 실패: {e}")
        return False
    
    # Node.js 및 pnpm 확인
    try:
        node_result = subprocess.run(['node', '--version'], capture_output=True, text=True)
        pnpm_result = subprocess.run(['pnpm', '--version'], capture_output=True, text=True)
        
        print(f"✅ Node.js: {node_result.stdout.strip()}")
        print(f"✅ pnpm: {pnpm_result.stdout.strip()}")
        
    except FileNotFoundError as e:
        print(f"❌ Node.js/pnpm 확인 실패: {e}")
        return False
    
    print("🎉 모든 설치가 완료되었습니다!")
    return True

if __name__ == "__main__":
    test_metagpt_installation()
EOF

# 간단한 프로젝트 생성 테스트
cat > simple_project_test.py << 'EOF'
import asyncio
import os
from pathlib import Path

async def test_simple_project():
    """간단한 프로젝트 생성 테스트"""
    
    # API 키 확인
    config_file = Path.home() / ".metagpt" / "config2.yaml"
    if not config_file.exists():
        print("❌ MetaGPT 설정 파일이 없습니다.")
        print("   다음 명령어로 설정하세요: metagpt --init-config")
        return False
    
    try:
        from metagpt.software_company import generate_repo
        from metagpt.utils.project_repo import ProjectRepo
        
        print("🚀 간단한 계산기 프로젝트 생성 중...")
        
        requirement = """
        Create a simple calculator web application with:
        1. Basic arithmetic operations (+, -, *, /)
        2. Clean HTML/CSS interface
        3. JavaScript functionality
        4. Input validation
        """
        
        # 프로젝트 생성
        repo: ProjectRepo = await generate_repo(requirement)
        
        print("✅ 프로젝트 생성 완료!")
        print(f"📁 프로젝트 위치: {repo}")
        
        # 생성된 파일들 확인
        print("\n📄 생성된 파일들:")
        for file_path in repo.all_files[:10]:  # 처음 10개만 표시
            print(f"   {file_path}")
        
        if len(repo.all_files) > 10:
            print(f"   ... 외 {len(repo.all_files) - 10}개 파일")
        
        return True
        
    except Exception as e:
        print(f"❌ 프로젝트 생성 실패: {e}")
        return False

if __name__ == "__main__":
    asyncio.run(test_simple_project())
EOF

# 데이터 분석 테스트
cat > data_analysis_test.py << 'EOF'
import asyncio

async def test_data_interpreter():
    """데이터 인터프리터 테스트"""
    
    try:
        from metagpt.roles.di.data_interpreter import DataInterpreter
        
        print("📊 데이터 분석 테스트 시작...")
        
        di = DataInterpreter()
        
        # 간단한 분석 요청
        result = await di.run("""
        Create a simple data analysis:
        1. Generate sample sales data for 12 months
        2. Calculate basic statistics (mean, median, std)
        3. Create a simple line chart
        4. Provide insights and recommendations
        """)
        
        print("✅ 데이터 분석 완료!")
        print("📈 결과가 workspace에 저장되었습니다.")
        
        return True
        
    except Exception as e:
        print(f"❌ 데이터 분석 실패: {e}")
        return False

if __name__ == "__main__":
    asyncio.run(test_data_interpreter())
EOF

echo "📄 권한 설정..."
chmod +x test_installation.py simple_project_test.py data_analysis_test.py

echo ""
echo "🎉 MetaGPT 테스트 환경 설정 완료!"
echo ""
echo "📋 다음 단계:"
echo "1. 가상환경 활성화: source metagpt-test-env/bin/activate"
echo "2. 설정 초기화: metagpt --init-config"
echo "3. API 키 설정: ~/.metagpt/config2.yaml 편집"
echo "4. 설치 확인: python test_installation.py"
echo "5. 간단한 테스트: python simple_project_test.py"
echo "6. 데이터 분석 테스트: python data_analysis_test.py"
echo ""
echo "💡 문제 발생 시:"
echo "   - API 키가 올바르게 설정되었는지 확인"
echo "   - 네트워크 연결 상태 확인"
echo "   - Python 버전이 3.9-3.11 범위인지 확인"
