#!/bin/bash
# test-pandasai-setup.sh

echo "🚀 PandasAI 테스트 환경 설정 시작"
echo "=================================="

# 시스템 요구사항 확인
echo "[INFO] 시스템 요구사항 확인 중..."

# Python 버전 확인
PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d'.' -f1)
PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d'.' -f2)

if [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 8 ] && [ "$PYTHON_MINOR" -lt 12 ]; then
    echo "[SUCCESS] Python 버전 확인: $PYTHON_VERSION (요구사항 충족)"
else
    echo "[ERROR] Python 3.8-3.11 버전이 필요합니다. 현재: $PYTHON_VERSION"
    echo "pyenv나 conda를 사용하여 적절한 Python 버전을 설치하세요."
    exit 1
fi

# pip 확인
if command -v pip3 &> /dev/null; then
    PIP_VERSION=$(pip3 --version | cut -d' ' -f2)
    echo "[SUCCESS] pip 설치됨: $PIP_VERSION"
else
    echo "[ERROR] pip3가 설치되지 않음"
    exit 1
fi

# 테스트 디렉토리 생성
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
TEST_DIR="$HOME/pandasai-test-$TIMESTAMP"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "[INFO] 테스트 디렉토리 생성: $TEST_DIR"

# 가상 환경 생성
echo "[INFO] Python 가상 환경 생성 중..."
python3 -m venv venv
source venv/bin/activate

# PandasAI 설치
echo "[INFO] PandasAI 및 필수 패키지 설치 중..."
pip install --upgrade pip
pip install "pandasai>=3.0.0b2"
pip install openai pandas matplotlib seaborn plotly numpy
pip install jupyter ipykernel  # Jupyter notebook 지원

# API 키 설정 확인
echo "[INFO] API 키 설정 확인 중..."
if [ -z "$OPENAI_API_KEY" ]; then
    echo "[WARNING] OPENAI_API_KEY 환경변수가 설정되지 않았습니다."
    echo "테스트를 위해 임시로 설정할 수 있습니다:"
    echo "export OPENAI_API_KEY='your-api-key-here'"
else
    echo "[SUCCESS] OPENAI_API_KEY 환경변수 설정됨"
fi

# 샘플 데이터 생성
echo "[INFO] 샘플 데이터 파일 생성 중..."

# CSV 샘플 데이터
cat > sample_sales_data.csv << 'EOF'
country,revenue,quarter,product_category
United States,5000,Q1,Electronics
United Kingdom,3200,Q1,Electronics
France,2900,Q1,Fashion
Germany,4100,Q1,Electronics
Italy,2300,Q1,Fashion
Spain,2100,Q1,Fashion
Canada,2500,Q1,Electronics
Australia,2600,Q1,Electronics
Japan,4500,Q1,Electronics
China,7000,Q1,Electronics
United States,5500,Q2,Electronics
United Kingdom,3400,Q2,Electronics
France,3100,Q2,Fashion
Germany,4300,Q2,Electronics
Italy,2500,Q2,Fashion
EOF

# 직원 데이터 CSV
cat > employee_data.csv << 'EOF'
employee_id,name,department,salary,performance_score,years_experience
1,John Smith,Engineering,75000,4.2,5
2,Emma Johnson,Sales,65000,4.5,3
3,Liam Brown,Engineering,80000,4.0,7
4,Olivia Davis,Marketing,70000,4.7,4
5,William Wilson,Finance,68000,4.1,6
6,Sophia Miller,Engineering,82000,4.6,8
7,James Garcia,Sales,62000,3.9,2
8,Isabella Martinez,Marketing,72000,4.4,5
9,Benjamin Anderson,Finance,71000,4.3,7
10,Mia Taylor,Engineering,85000,4.8,9
EOF

# 기본 테스트 스크립트 생성
cat > test_basic_functionality.py << 'EOF'
#!/usr/bin/env python3
"""
PandasAI 기본 기능 테스트 스크립트
"""

import os
import sys
import pandas as pd

# OpenAI API 키 확인
if not os.getenv('OPENAI_API_KEY'):
    print("⚠️  OPENAI_API_KEY 환경변수가 설정되지 않았습니다.")
    print("실제 테스트를 위해서는 API 키가 필요합니다.")
    print("export OPENAI_API_KEY='your-api-key-here'")
    sys.exit(1)

try:
    import pandasai as pai
    from pandasai_openai.openai import OpenAI
    print("✅ PandasAI 라이브러리 가져오기 성공")
except ImportError as e:
    print(f"❌ PandasAI 가져오기 실패: {e}")
    sys.exit(1)

def test_basic_dataframe():
    """기본 DataFrame 기능 테스트"""
    print("\n🧪 기본 DataFrame 기능 테스트")
    
    # LLM 설정
    llm = OpenAI()
    pai.config.set({"llm": llm})
    
    # 샘플 데이터 생성
    df = pai.DataFrame({
        "country": ["United States", "United Kingdom", "France", "Germany", "Italy"],
        "revenue": [5000, 3200, 2900, 4100, 2300]
    })
    
    print("📊 샘플 데이터:")
    print(df.head())
    
    try:
        # 간단한 질문 테스트
        result = df.chat('Which country has the highest revenue?')
        print(f"🔍 질문: Which country has the highest revenue?")
        print(f"💬 답변: {result}")
        return True
    except Exception as e:
        print(f"❌ 기본 질문 테스트 실패: {e}")
        return False

def test_csv_loading():
    """CSV 파일 로딩 테스트"""
    print("\n🧪 CSV 파일 로딩 테스트")
    
    try:
        # CSV 파일 로드
        df = pai.read_csv('sample_sales_data.csv')
        print("📄 CSV 파일 로드 성공")
        print(f"데이터 형태: {df.shape}")
        print(df.head())
        
        # CSV 데이터로 질문
        result = df.chat('What is the total revenue across all countries?')
        print(f"🔍 질문: What is the total revenue across all countries?")
        print(f"💬 답변: {result}")
        return True
    except Exception as e:
        print(f"❌ CSV 테스트 실패: {e}")
        return False

def test_multiple_dataframes():
    """다중 DataFrame 테스트"""
    print("\n🧪 다중 DataFrame 테스트")
    
    try:
        # 직원 데이터 로드
        employees_df = pai.read_csv('employee_data.csv')
        
        # 부서별 급여 데이터 생성
        dept_budget = pai.DataFrame({
            'department': ['Engineering', 'Sales', 'Marketing', 'Finance'],
            'budget': [500000, 300000, 250000, 200000]
        })
        
        print("👥 직원 데이터:")
        print(employees_df.head())
        print("\n💰 부서 예산 데이터:")
        print(dept_budget.head())
        
        # 다중 DataFrame 질의
        result = pai.chat(
            "Which department has the best budget utilization (budget vs total salaries)?",
            employees_df,
            dept_budget
        )
        print(f"🔍 질문: Which department has the best budget utilization?")
        print(f"💬 답변: {result}")
        return True
    except Exception as e:
        print(f"❌ 다중 DataFrame 테스트 실패: {e}")
        return False

def test_visualization():
    """시각화 기능 테스트"""
    print("\n🧪 시각화 기능 테스트")
    
    try:
        # 샘플 데이터 로드
        df = pai.read_csv('sample_sales_data.csv')
        
        print("📊 차트 생성 테스트 중...")
        # 차트 생성 (실제로는 표시되지 않지만 오류 없이 실행되는지 확인)
        result = df.chat('Create a bar chart showing revenue by country')
        print(f"🎨 시각화 결과: {result}")
        return True
    except Exception as e:
        print(f"❌ 시각화 테스트 실패: {e}")
        return False

if __name__ == "__main__":
    print("🚀 PandasAI 기능 테스트 시작")
    print("=" * 50)
    
    # 테스트 실행
    tests = [
        test_basic_dataframe,
        test_csv_loading,
        test_multiple_dataframes,
        test_visualization
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        try:
            if test():
                passed += 1
                print("✅ 테스트 통과")
            else:
                print("❌ 테스트 실패")
        except Exception as e:
            print(f"❌ 테스트 실행 중 오류: {e}")
    
    print("\n" + "=" * 50)
    print(f"📊 테스트 결과: {passed}/{total} 통과")
    
    if passed == total:
        print("🎉 모든 테스트가 성공적으로 완료되었습니다!")
        print("\n💡 다음 단계:")
        print("1. jupyter notebook pandasai_tutorial.ipynb 실행")
        print("2. 실제 데이터로 분석 시작")
        print("3. 고급 기능 탐색")
    else:
        print("⚠️  일부 테스트가 실패했습니다. API 키 설정을 확인하세요.")
EOF

# Jupyter 노트북 샘플 생성
cat > pandasai_tutorial.ipynb << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# PandasAI 튜토리얼 노트북\n",
    "\n",
    "이 노트북은 PandasAI의 기본 기능을 단계별로 학습할 수 있도록 구성되었습니다."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# 필수 라이브러리 가져오기\n",
    "import pandasai as pai\n",
    "from pandasai_openai.openai import OpenAI\n",
    "import pandas as pd\n",
    "import matplotlib.pyplot as plt\n",
    "print(\"라이브러리 가져오기 완료!\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# LLM 설정\n",
    "llm = OpenAI()  # API 키는 환경변수에서 자동 로드\n",
    "pai.config.set({\"llm\": llm})\n",
    "print(\"LLM 설정 완료!\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# 샘플 데이터 생성\n",
    "df = pai.DataFrame({\n",
    "    \"country\": [\"United States\", \"United Kingdom\", \"France\", \"Germany\", \"Italy\", \"Spain\", \"Canada\", \"Australia\", \"Japan\", \"China\"],\n",
    "    \"revenue\": [5000, 3200, 2900, 4100, 2300, 2100, 2500, 2600, 4500, 7000]\n",
    "})\n",
    "\n",
    "print(\"데이터 미리보기:\")\n",
    "df.head()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# 자연어 질문 예제 1\n",
    "result = df.chat('Which are the top 3 countries by revenue?')\n",
    "print(f\"질문: Which are the top 3 countries by revenue?\")\n",
    "print(f\"답변: {result}\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# 자연어 질문 예제 2\n",
    "result = df.chat('What is the total revenue for all countries?')\n",
    "print(f\"질문: What is the total revenue for all countries?\")\n",
    "print(f\"답변: {result}\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# 통계 분석 예제\n",
    "result = df.chat('Calculate the average revenue and show me the standard deviation')\n",
    "print(f\"질문: Calculate the average revenue and show me the standard deviation\")\n",
    "print(f\"답변: {result}\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# 시각화 예제\n",
    "df.chat('Create a bar chart showing revenue by country, sorted from highest to lowest')"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# CSV 데이터 로드 예제\n",
    "sales_df = pai.read_csv('sample_sales_data.csv')\n",
    "print(\"CSV 데이터 로드 완료:\")\n",
    "print(sales_df.head())"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# CSV 데이터 분석\n",
    "result = sales_df.chat('Compare the performance between Q1 and Q2. Which quarter was better?')\n",
    "print(f\"분석 결과: {result}\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# 다중 DataFrame 분석 예제\n",
    "employees_df = pai.read_csv('employee_data.csv')\n",
    "\n",
    "# 부서별 예산 데이터\n",
    "budget_df = pai.DataFrame({\n",
    "    'department': ['Engineering', 'Sales', 'Marketing', 'Finance'],\n",
    "    'budget': [500000, 300000, 250000, 200000]\n",
    "})\n",
    "\n",
    "print(\"다중 DataFrame 준비 완료\")\n",
    "print(\"직원 데이터:\")\n",
    "print(employees_df.head(3))\n",
    "print(\"\\n예산 데이터:\")\n",
    "print(budget_df.head())"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# 복합 분석 질의\n",
    "result = pai.chat(\n",
    "    \"Analyze the relationship between employee performance scores and salaries. Also show department-wise analysis.\",\n",
    "    employees_df,\n",
    "    budget_df\n",
    ")\n",
    "print(f\"복합 분석 결과: {result}\")"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 추가 실험\n",
    "\n",
    "아래 셀에서 자유롭게 질문을 해보세요!"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# 자유 실험용 셀\n",
    "# 여기에 원하는 질문을 입력해보세요\n",
    "\n",
    "your_question = \"Create a pie chart showing the distribution of employees by department\"\n",
    "result = employees_df.chat(your_question)\n",
    "print(f\"질문: {your_question}\")\n",
    "print(f\"답변: {result}\")"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.9.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF

# 실행 권한 부여
chmod +x test_basic_functionality.py

# 빠른 테스트 명령어 모음 생성
cat > quick_test_commands.txt << 'EOF'
# PandasAI 빠른 테스트 명령어 모음

## 기본 설정
source venv/bin/activate  # 가상환경 활성화

## API 키 설정 (필수)
export OPENAI_API_KEY='your-openai-api-key-here'

## Python 테스트
python test_basic_functionality.py  # 기본 기능 테스트

## Jupyter 노트북 실행
jupyter notebook pandasai_tutorial.ipynb

## 패키지 설치 확인
pip list | grep pandas
pip show pandasai

## 대화형 Python으로 빠른 테스트
python3 -c "
import pandasai as pai
from pandasai_openai.openai import OpenAI
print('PandasAI 버전:', pai.__version__)
print('설치 성공!')
"

## CSV 데이터 확인
head -5 sample_sales_data.csv
head -5 employee_data.csv

## 환경변수 확인
echo $OPENAI_API_KEY | cut -c1-10  # API 키 앞 10자리만 표시

## 간단한 대화형 테스트
python3 -i -c "
import pandasai as pai
from pandasai_openai.openai import OpenAI
import os

if os.getenv('OPENAI_API_KEY'):
    llm = OpenAI()
    pai.config.set({'llm': llm})
    df = pai.DataFrame({'test': [1, 2, 3, 4, 5]})
    print('PandasAI 준비 완료! df.chat() 사용 가능')
else:
    print('API 키를 먼저 설정하세요: export OPENAI_API_KEY=your-key')
"
EOF

# 환경 정보 저장
cat > test_environment_info.txt << EOF
PandasAI 테스트 환경 정보
========================

생성 시간: $(date)
Python 버전: $(python3 --version)
pip 버전: $(pip3 --version)
테스트 디렉토리: $TEST_DIR
가상환경: $TEST_DIR/venv

필수 패키지 설치 상태:
$(pip list 2>/dev/null | grep -E "(pandas|numpy|matplotlib|seaborn|plotly|openai)" || echo "아직 설치되지 않음")

시스템 정보:
OS: $(uname -s)
아키텍처: $(uname -m)
메모리: $(sysctl -n hw.memsize 2>/dev/null | awk '{print $1/1024/1024/1024 " GB"}' || echo "확인 불가")

생성된 파일들:
$(ls -la | grep -v "^d")

PandasAI 특징:
- 자연어 기반 데이터 분석
- 다중 DataFrame 지원
- 자동 시각화 생성
- LLM 기반 인사이트 제공
EOF

echo ""
echo "🎉 PandasAI 테스트 환경 설정 완료!"
echo "================================="
echo ""
echo "📁 테스트 디렉토리: $TEST_DIR"
echo ""
echo "🚀 다음 단계:"
echo "1. cd $TEST_DIR"
echo "2. source venv/bin/activate  # 가상환경 활성화"
echo "3. export OPENAI_API_KEY='your-api-key-here'  # API 키 설정 (필수)"
echo "4. python test_basic_functionality.py  # 기본 테스트 실행"
echo ""
echo "📋 생성된 유용한 파일들:"
echo "- test_basic_functionality.py: 기본 기능 테스트 스크립트"
echo "- pandasai_tutorial.ipynb: Jupyter 노트북 튜토리얼"
echo "- sample_sales_data.csv: 매출 샘플 데이터"
echo "- employee_data.csv: 직원 데이터 샘플"
echo "- quick_test_commands.txt: 빠른 명령어 참조"
echo ""
echo "💡 중요한 팁:"
echo "- OpenAI API 키가 반드시 필요합니다 (https://platform.openai.com/api-keys)"
echo "- 가상환경을 활성화한 후 테스트를 실행하세요"
echo "- Jupyter 노트북으로 인터랙티브한 학습이 가능합니다"
echo "- 실제 데이터 분석 전에 샘플 데이터로 먼저 연습하세요"

# 사용자에게 API 키 설정 안내
echo ""
if [ -z "$OPENAI_API_KEY" ]; then
    echo "⚠️  OpenAI API 키를 설정하고 테스트를 시작하세요:"
    echo "export OPENAI_API_KEY='your-api-key-here'"
    echo ""
    read -p "지금 API 키를 입력하시겠습니까? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "API 키를 입력하세요 (입력이 숨겨집니다):"
        read -s API_KEY
        export OPENAI_API_KEY="$API_KEY"
        echo "API 키가 설정되었습니다."
        echo ""
        echo "🧪 기본 테스트를 실행하시겠습니까? (y/n): "
        read -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "테스트 실행 중..."
            python test_basic_functionality.py
        fi
    else
        echo "나중에 API 키를 설정한 후 테스트를 실행하세요."
    fi
else
    echo "✅ API 키가 이미 설정되어 있습니다."
    echo ""
    read -p "지금 기본 테스트를 실행하시겠습니까? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "테스트 실행 중..."
        python test_basic_functionality.py
    fi
fi

echo ""
echo "🎯 테스트 완료 후 할 일:"
echo "1. Jupyter 노트북으로 더 깊이 있는 학습"
echo "2. 실제 CSV 데이터로 분석 실험"
echo "3. 다양한 자연어 질문 시도해보기"
echo "4. 시각화 기능 탐색"
echo "5. 실제 비즈니스 문제에 적용"
echo ""
echo "📚 추가 학습 자료:"
echo "- PandasAI 공식 문서: https://docs.pandas-ai.com"
echo "- GitHub 리포지토리: https://github.com/sinaptik-ai/pandas-ai"
echo "- 커뮤니티: Discord 서버 참여"
