---
title: "PandasAI: 자연어로 데이터 분석하는 대화형 AI 플랫폼 완전 가이드"
excerpt: "PandasAI로 SQL, CSV, Parquet 데이터를 자연어로 질문하고 분석하는 방법. LLM과 RAG를 활용한 혁신적인 데이터 분석 도구의 설치부터 고급 활용까지 완벽 정리"
seo_title: "PandasAI 대화형 데이터 분석 완전 가이드 - Python LLM RAG - Thaki Cloud"
seo_description: "PandasAI로 자연어 질문만으로 데이터 분석을 수행하는 방법. 설치부터 Docker 샌드박스, 다중 DataFrame, 시각화까지 macOS 테스트 예제 포함"
date: 2025-08-15
last_modified_at: 2025-08-15
categories:
  - tutorials
tags:
  - pandasai
  - data-analysis
  - llm
  - rag
  - natural-language
  - data-science
  - pandas
  - openai
  - conversational-ai
  - python
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/pandasai-conversational-data-analysis-complete-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 15분

## 개요

**[PandasAI](https://github.com/sinaptik-ai/pandas-ai)**는 데이터 분석을 혁신적으로 간소화하는 Python 플랫폼입니다. 복잡한 pandas 코드나 SQL 쿼리를 작성하는 대신, **자연어로 질문하기만 하면 AI가 데이터를 분석하고 인사이트를 제공**합니다. 21.8k 스타를 받은 이 오픈소스 프로젝트는 LLM(Large Language Model)과 RAG(Retrieval Augmented Generation) 기술을 활용하여 비전문가도 쉽게 데이터 분석을 할 수 있게 도와줍니다.

### 🎯 PandasAI의 핵심 가치

- **자연어 기반 데이터 질의**: "매출이 가장 높은 상위 5개 국가는?"
- **다양한 데이터 소스 지원**: SQL, CSV, Parquet, Excel 등
- **AI 기반 시각화**: 차트와 그래프 자동 생성
- **비전문가 친화적**: 코딩 지식 없이도 데이터 분석 가능
- **확장 가능한 아키텍처**: 다중 DataFrame 및 복잡한 분석 지원

### 🚀 주요 특징

**대화형 인터페이스**:
- 자연어로 데이터에 질문
- 맥락을 이해하는 연속적 대화
- 즉각적인 답변과 시각화

**안전한 실행 환경**:
- Docker 샌드박스 지원
- 악성 코드 실행 방지
- 격리된 환경에서 안전한 분석

**다양한 LLM 지원**:
- OpenAI GPT 모델
- Claude, Gemini 등 주요 LLM
- 로컬 LLM 모델도 지원

## 설치 및 환경 구성

### 📋 시스템 요구사항

```bash
# Python 버전 요구사항
Python 3.8+ < 3.12

# 권장 환경
- macOS 10.15+, Ubuntu 18.04+, Windows 10+
- 8GB+ RAM (대용량 데이터 분석 시)
- 인터넷 연결 (LLM API 사용)
```

### 🔧 기본 설치

#### pip를 통한 설치
```bash
# 최신 베타 버전 설치 (권장)
pip install "pandasai>=3.0.0b2"

# 추가 의존성 패키지
pip install openai pandas matplotlib seaborn plotly
```

#### Poetry를 통한 설치
```bash
# Poetry 사용자용
poetry add "pandasai>=3.0.0b2"
poetry add openai pandas matplotlib seaborn plotly
```

#### Docker 샌드박스 설치 (선택사항)
```bash
# 보안 강화를 위한 Docker 샌드박스
pip install "pandasai-docker"

# Docker 설치 확인
docker --version
```

### 🔑 API 키 설정

#### OpenAI API 키 설정
```bash
# 환경변수로 설정 (권장)
export OPENAI_API_KEY="your-openai-api-key-here"

# 또는 .env 파일 생성
echo "OPENAI_API_KEY=your-openai-api-key-here" > .env
```

#### 기타 LLM 설정
```bash
# Claude API
export ANTHROPIC_API_KEY="your-claude-api-key"

# Google Gemini
export GOOGLE_API_KEY="your-gemini-api-key"

# Azure OpenAI
export AZURE_OPENAI_API_KEY="your-azure-key"
export AZURE_OPENAI_ENDPOINT="your-azure-endpoint"
```

## 핵심 기능 및 사용법

### 🚀 기본 사용법

#### 간단한 데이터 분석
```python
import pandasai as pai
from pandasai_openai.openai import OpenAI

# LLM 설정
llm = OpenAI("OPEN_AI_API_KEY")  # 또는 환경변수에서 자동 로드

pai.config.set({
    "llm": llm
})

# 샘플 데이터 생성
df = pai.DataFrame({
    "country": ["United States", "United Kingdom", "France", "Germany", "Italy", "Spain", "Canada", "Australia", "Japan", "China"],
    "revenue": [5000, 3200, 2900, 4100, 2300, 2100, 2500, 2600, 4500, 7000]
})

# 자연어로 질문하기
result = df.chat('Which are the top 5 countries by sales?')
print(result)
# 출력: China, United States, Japan, Germany, Australia
```

#### 복잡한 계산 질의
```python
# 수치 계산 질문
total_sales = df.chat(
    "What is the total sales for the top 3 countries by sales?"
)
print(total_sales)
# 출력: The total sales for the top 3 countries by sales is 16500.

# 평균 및 통계 질문
average_revenue = df.chat(
    "What is the average revenue? Also tell me the median and standard deviation."
)
print(average_revenue)

# 조건부 필터링
european_sales = df.chat(
    "What is the total revenue for European countries only?"
)
print(european_sales)
```

### 📊 시각화 기능

#### 자동 차트 생성
```python
# 히스토그램 생성
df.chat(
    "Plot the histogram of countries showing for each one the revenue. Use different colors for each bar"
)

# 파이 차트 생성
df.chat(
    "Create a pie chart showing the revenue distribution by country"
)

# 막대 그래프
df.chat(
    "Show me a bar chart of revenue by country, sorted from highest to lowest"
)

# 시계열 분석 (날짜 데이터가 있는 경우)
df.chat(
    "Plot the revenue trend over time with a line chart"
)
```

#### 고급 시각화
```python
# 다중 시각화
df.chat(
    """
    Create a dashboard with:
    1. A bar chart of top 5 countries by revenue
    2. A pie chart of revenue distribution
    3. A summary table with statistics
    """
)

# 사용자 정의 스타일
df.chat(
    "Create a professional-looking chart with revenue by country. Use blue gradient colors and add data labels."
)
```

### 🔗 다중 DataFrame 분석

#### 관련 데이터 결합 분석
```python
import pandasai as pai
from pandasai_openai.openai import OpenAI

# 직원 데이터
employees_data = {
    'EmployeeID': [1, 2, 3, 4, 5],
    'Name': ['John', 'Emma', 'Liam', 'Olivia', 'William'],
    'Department': ['HR', 'Sales', 'IT', 'Marketing', 'Finance']
}

# 급여 데이터
salaries_data = {
    'EmployeeID': [1, 2, 3, 4, 5],
    'Salary': [5000, 6000, 4500, 7000, 5500]
}

llm = OpenAI()
pai.config.set({"llm": llm})

employees_df = pai.DataFrame(employees_data)
salaries_df = pai.DataFrame(salaries_data)

# 다중 DataFrame 질의
result = pai.chat("Who gets paid the most?", employees_df, salaries_df)
print(result)
# 출력: Olivia gets paid the most.

# 복잡한 조인 분석
department_analysis = pai.chat(
    "What is the average salary by department? Show me in descending order.",
    employees_df, 
    salaries_df
)
print(department_analysis)
```

#### 고급 다중 데이터 분석
```python
# 매출 데이터
sales_data = {
    'EmployeeID': [1, 2, 3, 4, 5],
    'Sales': [150000, 200000, 120000, 250000, 180000],
    'Quarter': ['Q1', 'Q1', 'Q1', 'Q1', 'Q1']
}

sales_df = pai.DataFrame(sales_data)

# 세 개 DataFrame 동시 분석
comprehensive_analysis = pai.chat(
    """
    Analyze the relationship between department, salary, and sales performance. 
    Which department has the best ROI (sales vs salary cost)?
    """,
    employees_df, 
    salaries_df, 
    sales_df
)
print(comprehensive_analysis)
```

### 🐳 Docker 샌드박스 활용

#### 보안 강화된 실행 환경
```python
import pandasai as pai
from pandasai_docker import DockerSandbox
from pandasai_openai.openai import OpenAI

# Docker 샌드박스 초기화
sandbox = DockerSandbox()
sandbox.start()

try:
    # LLM 설정
    llm = OpenAI()
    pai.config.set({"llm": llm})
    
    # 위험할 수 있는 데이터 분석도 안전하게 실행
    df = pai.DataFrame({
        "user_data": ["sensitive_info_1", "sensitive_info_2"],
        "values": [100, 200]
    })
    
    # 샌드박스에서 안전하게 실행
    result = pai.chat(
        "Analyze this data and create a summary report",
        df,
        sandbox=sandbox
    )
    print(result)
    
finally:
    # 샌드박스 정리
    sandbox.stop()
```

#### 대용량 데이터 처리
```python
# 대용량 파일 처리 시 Docker 활용
sandbox = DockerSandbox()
sandbox.start()

# 메모리 제한 설정
sandbox.configure(memory_limit="4g", cpu_limit="2")

large_df = pai.read_csv("large_dataset.csv")  # 가상의 대용량 파일

result = pai.chat(
    "Find patterns in this large dataset and summarize key insights",
    large_df,
    sandbox=sandbox
)

sandbox.stop()
```

## 실전 활용 예제

### 📈 비즈니스 데이터 분석

#### 매출 분석 대시보드
```python
import pandasai as pai
import pandas as pd
from pandasai_openai.openai import OpenAI

# 실제 비즈니스 데이터 시뮬레이션
business_data = {
    'date': pd.date_range('2024-01-01', periods=365, freq='D'),
    'product': ['A', 'B', 'C'] * 122,  # 365개 생성을 위해 반복
    'sales': [100 + i*2 + (i%30)*10 for i in range(365)],
    'region': ['North', 'South', 'East', 'West'] * 91 + ['North'],
    'customer_type': ['B2B', 'B2C'] * 182 + ['B2B']
}

llm = OpenAI()
pai.config.set({"llm": llm})

business_df = pai.DataFrame(business_data)

# 종합 비즈니스 인사이트
insights = business_df.chat(
    """
    Provide a comprehensive business analysis including:
    1. Monthly sales trends
    2. Best performing products
    3. Regional performance comparison
    4. B2B vs B2C customer analysis
    5. Recommendations for improvement
    """
)
print(insights)
```

#### 고객 세분화 분석
```python
# 고객 데이터 준비
customer_data = {
    'customer_id': range(1, 1001),
    'age': [25 + i%40 for i in range(1000)],
    'annual_spend': [1000 + i*5 + (i%100)*20 for i in range(1000)],
    'frequency': [1 + i%50 for i in range(1000)],
    'last_purchase_days': [1 + i%365 for i in range(1000)],
    'category_preference': ['Electronics', 'Fashion', 'Home', 'Sports'] * 250
}

customer_df = pai.DataFrame(customer_data)

# AI 기반 고객 세분화
segmentation = customer_df.chat(
    """
    Perform customer segmentation analysis:
    1. Identify different customer segments based on spending and frequency
    2. Create customer personas for each segment
    3. Suggest targeted marketing strategies
    4. Show the distribution of customers across segments with visualization
    """
)
print(segmentation)
```

### 🔬 데이터 과학 활용

#### 통계 분석 및 가설 검정
```python
# 실험 데이터 생성
import numpy as np

experiment_data = {
    'group': ['A'] * 500 + ['B'] * 500,
    'conversion_rate': (
        list(np.random.normal(0.15, 0.05, 500)) +  # A그룹
        list(np.random.normal(0.18, 0.05, 500))    # B그룹
    ),
    'session_duration': (
        list(np.random.normal(120, 30, 500)) +  # A그룹
        list(np.random.normal(135, 35, 500))    # B그룹
    )
}

experiment_df = pai.DataFrame(experiment_data)

# AI 기반 통계 분석
statistical_analysis = experiment_df.chat(
    """
    Perform A/B test analysis:
    1. Calculate statistical significance of conversion rate difference
    2. Analyze session duration differences
    3. Provide confidence intervals
    4. Create visualization showing the results
    5. Give business recommendations based on the results
    """
)
print(statistical_analysis)
```

#### 예측 모델링 지원
```python
# 시계열 데이터 준비
time_series_data = {
    'date': pd.date_range('2020-01-01', periods=1460, freq='D'),  # 4년간 데이터
    'sales': [
        1000 + 50*np.sin(i*2*np.pi/365) + 10*np.sin(i*2*np.pi/7) + np.random.normal(0, 20)
        for i in range(1460)
    ],
    'marketing_spend': [100 + i*0.1 + np.random.normal(0, 10) for i in range(1460)],
    'temperature': [20 + 15*np.sin((i-90)*2*np.pi/365) + np.random.normal(0, 3) for i in range(1460)]
}

ts_df = pai.DataFrame(time_series_data)

# AI 기반 예측 분석
forecast_analysis = ts_df.chat(
    """
    Analyze this time series data and provide:
    1. Trend analysis and seasonality patterns
    2. Correlation between marketing spend, temperature, and sales
    3. Anomaly detection for unusual patterns
    4. Sales forecast for the next 30 days
    5. Visualization of trends and forecasts
    """
)
print(forecast_analysis)
```

### 🏢 실무 활용 시나리오

#### 재무 보고서 자동화
```python
# 재무 데이터 시뮬레이션
financial_data = {
    'account': ['Revenue', 'COGS', 'Marketing', 'R&D', 'Admin', 'Interest'],
    'Q1_2024': [1000000, -400000, -150000, -200000, -100000, -25000],
    'Q2_2024': [1200000, -480000, -180000, -220000, -110000, -25000],
    'Q3_2024': [1150000, -460000, -170000, -210000, -105000, -25000],
    'Q4_2024': [1300000, -520000, -200000, -240000, -120000, -25000],
    'category': ['Income', 'COGS', 'OpEx', 'OpEx', 'OpEx', 'FinEx']
}

financial_df = pai.DataFrame(financial_data)

# 자동 재무 분석 보고서
financial_report = financial_df.chat(
    """
    Generate a comprehensive financial analysis report:
    1. Calculate quarterly profit margins and growth rates
    2. Analyze expense ratios and trends
    3. Create quarterly comparison charts
    4. Identify areas of concern and opportunities
    5. Provide executive summary with key recommendations
    """
)
print(financial_report)
```

#### HR 데이터 분석
```python
# HR 데이터 준비
hr_data = {
    'employee_id': range(1, 201),
    'department': ['Engineering', 'Sales', 'Marketing', 'HR', 'Finance'] * 40,
    'salary': [50000 + i*1000 + np.random.normal(0, 5000) for i in range(200)],
    'performance_score': [3 + np.random.normal(0, 0.8) for _ in range(200)],
    'years_at_company': [np.random.randint(1, 15) for _ in range(200)],
    'satisfaction_score': [3 + np.random.normal(0, 1) for _ in range(200)],
    'attrition_risk': ['Low', 'Medium', 'High'] * 66 + ['Low', 'Medium']
}

hr_df = pai.DataFrame(hr_data)

# HR 인사이트 분석
hr_insights = hr_df.chat(
    """
    Perform comprehensive HR analytics:
    1. Salary benchmarking by department and experience
    2. Performance vs satisfaction correlation analysis
    3. Attrition risk factors identification
    4. Department-wise retention strategies
    5. Diversity and equity analysis
    6. Create actionable recommendations for HR team
    """
)
print(hr_insights)
```

## macOS 테스트 환경 구성

### 🧪 테스트 스크립트 작성

PandasAI의 실제 동작을 확인하기 위한 macOS 테스트 환경을 구성해보겠습니다.

#### 테스트 환경 설정 스크립트

```bash
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

if __name__ == "__main__":
    print("🚀 PandasAI 기능 테스트 시작")
    print("=" * 50)
    
    # 테스트 실행
    tests = [
        test_basic_dataframe,
        test_csv_loading,
        test_multiple_dataframes
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
    "import matplotlib.pyplot as plt"
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
    "pai.config.set({\"llm\": llm})"
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
    "    \"country\": [\"United States\", \"United Kingdom\", \"France\", \"Germany\", \"Italy\"],\n",
    "    \"revenue\": [5000, 3200, 2900, 4100, 2300]\n",
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
    "# 자연어 질문 예제\n",
    "result = df.chat('Which are the top 3 countries by revenue?')\n",
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
    "df.chat('Create a bar chart showing revenue by country')"
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

# Docker 테스트 스크립트 (선택사항)
cat > test_docker_sandbox.py << 'EOF'
#!/usr/bin/env python3
"""
PandasAI Docker 샌드박스 테스트 스크립트
"""

import os
import sys

def test_docker_availability():
    """Docker 설치 확인"""
    import subprocess
    try:
        result = subprocess.run(['docker', '--version'], capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ Docker 설치됨: {result.stdout.strip()}")
            return True
        else:
            print("❌ Docker가 설치되지 않았거나 실행되지 않습니다.")
            return False
    except FileNotFoundError:
        print("❌ Docker가 설치되지 않았습니다.")
        return False

def test_docker_sandbox():
    """Docker 샌드박스 기능 테스트"""
    if not test_docker_availability():
        return False
    
    try:
        import pandasai as pai
        from pandasai_docker import DockerSandbox
        from pandasai_openai.openai import OpenAI
        
        print("🐳 Docker 샌드박스 테스트 시작")
        
        # 샌드박스 초기화
        sandbox = DockerSandbox()
        sandbox.start()
        
        try:
            # LLM 설정
            llm = OpenAI()
            pai.config.set({"llm": llm})
            
            # 테스트 데이터
            df = pai.DataFrame({
                "category": ["A", "B", "C"],
                "values": [10, 20, 30]
            })
            
            # 샌드박스에서 실행
            result = pai.chat(
                "What is the sum of all values?",
                df,
                sandbox=sandbox
            )
            
            print(f"🔍 질문: What is the sum of all values?")
            print(f"💬 답변: {result}")
            print("✅ Docker 샌드박스 테스트 성공")
            return True
            
        finally:
            sandbox.stop()
            
    except ImportError:
        print("❌ pandasai-docker 패키지가 설치되지 않았습니다.")
        print("pip install pandasai-docker 로 설치하세요.")
        return False
    except Exception as e:
        print(f"❌ Docker 샌드박스 테스트 실패: {e}")
        return False

if __name__ == "__main__":
    print("🐳 Docker 샌드박스 테스트")
    print("=" * 40)
    
    if not os.getenv('OPENAI_API_KEY'):
        print("⚠️  OPENAI_API_KEY 환경변수가 설정되지 않았습니다.")
        sys.exit(1)
    
    if test_docker_sandbox():
        print("🎉 Docker 샌드박스가 정상적으로 작동합니다!")
    else:
        print("❌ Docker 샌드박스 테스트에 실패했습니다.")
EOF

# 실행 권한 부여
chmod +x test_basic_functionality.py
chmod +x test_docker_sandbox.py

# 빠른 테스트 명령어 모음 생성
cat > quick_test_commands.txt << 'EOF'
# PandasAI 빠른 테스트 명령어 모음

## 기본 설정
source venv/bin/activate  # 가상환경 활성화

## Python 테스트
python test_basic_functionality.py  # 기본 기능 테스트
python test_docker_sandbox.py       # Docker 샌드박스 테스트

## Jupyter 노트북 실행
jupyter notebook pandasai_tutorial.ipynb

## 패키지 설치 확인
pip list | grep pandas
pip show pandasai

## 대화형 Python으로 빠른 테스트
python3 -c "
import pandasai as pai
print('PandasAI 버전:', pai.__version__)
print('설치 성공!')
"

## CSV 데이터 확인
head -5 sample_sales_data.csv
head -5 employee_data.csv

## 환경변수 확인
echo $OPENAI_API_KEY | cut -c1-10  # API 키 앞 10자리만 표시
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

설치된 패키지:
$(pip list | grep -E "(pandas|numpy|matplotlib|seaborn|plotly)")

시스템 정보:
OS: $(uname -s)
아키텍처: $(uname -m)
메모리: $(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024 " GB"}' 2>/dev/null || echo "확인 불가")

생성된 파일들:
$(ls -la | grep -v "^d")
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
echo "3. export OPENAI_API_KEY='your-api-key-here'  # API 키 설정"
echo "4. python test_basic_functionality.py  # 기본 테스트 실행"
echo ""
echo "📋 생성된 유용한 파일들:"
echo "- test_basic_functionality.py: 기본 기능 테스트"
echo "- test_docker_sandbox.py: Docker 샌드박스 테스트"
echo "- pandasai_tutorial.ipynb: Jupyter 노트북 튜토리얼"
echo "- sample_sales_data.csv: 샘플 데이터"
echo "- employee_data.csv: 직원 데이터 샘플"
echo "- quick_test_commands.txt: 빠른 명령어 참조"
echo ""
echo "💡 팁:"
echo "- OpenAI API 키가 필요합니다 (https://platform.openai.com/api-keys)"
echo "- 가상환경을 활성화한 후 테스트를 실행하세요"
echo "- Jupyter 노트북으로 인터랙티브한 학습이 가능합니다"

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
echo "1. 생성된 차트와 결과 확인"
echo "2. 다른 질문들로 추가 테스트"
echo "3. Jupyter 노트북으로 고급 기능 탐색"
echo "4. 실제 데이터로 프로젝트 시작"
```

### 🔧 zshrc Aliases 설정

PandasAI를 더 효율적으로 사용하기 위한 zsh aliases:

```bash
# ~/.zshrc에 추가할 PandasAI 관련 alias들

# PandasAI 기본 명령어 단축
alias pai-env="source venv/bin/activate"
alias pai-test="python test_basic_functionality.py"
alias pai-docker="python test_docker_sandbox.py"
alias pai-notebook="jupyter notebook pandasai_tutorial.ipynb"

# 가상환경 관리
alias pai-setup="python3 -m venv venv && source venv/bin/activate && pip install 'pandasai>=3.0.0b2' openai pandas matplotlib seaborn plotly"
alias pai-activate="source venv/bin/activate"
alias pai-deactivate="deactivate"

# 패키지 관리
alias pai-install="pip install 'pandasai>=3.0.0b2' openai pandas matplotlib seaborn plotly numpy jupyter"
alias pai-upgrade="pip install --upgrade 'pandasai>=3.0.0b2' openai pandas"
alias pai-packages="pip list | grep -E '(pandas|numpy|matplotlib|seaborn|plotly|openai)'"

# 데이터 파일 관리
alias pai-data="ls -la *.csv *.json *.parquet 2>/dev/null || echo 'No data files found'"
alias pai-sample="head -5 sample_sales_data.csv && echo '---' && head -5 employee_data.csv"

# 개발 도구
alias pai-python="python3 -i -c 'import pandasai as pai; from pandasai_openai.openai import OpenAI; print(\"PandasAI ready!\")'"
alias pai-version="python3 -c 'import pandasai as pai; print(f\"PandasAI version: {pai.__version__}\")'"

# API 키 관리
alias pai-key-check="echo \$OPENAI_API_KEY | cut -c1-10"
alias pai-key-set="echo 'export OPENAI_API_KEY=your-key-here' >> ~/.zshrc && source ~/.zshrc"

# 프로젝트 관리
alias pai-new="mkdir pandasai-project && cd pandasai-project && pai-setup"
alias pai-clean="rm -rf __pycache__ .pytest_cache *.pyc"

# 테스트 디렉토리 관리
alias pai-test-dir="cd ~/pandasai-test-* 2>/dev/null || echo 'No test directory found'"
alias pai-find-tests="find ~ -name 'pandasai-test-*' -type d 2>/dev/null"
```

#### Aliases 적용 방법

```bash
# zshrc에 aliases 추가
cat >> ~/.zshrc << 'EOF'

# PandasAI Development Aliases
alias pai-env="source venv/bin/activate"
alias pai-test="python test_basic_functionality.py"
alias pai-notebook="jupyter notebook pandasai_tutorial.ipynb"
alias pai-setup="python3 -m venv venv && source venv/bin/activate && pip install 'pandasai>=3.0.0b2' openai pandas matplotlib seaborn plotly"
alias pai-python="python3 -i -c 'import pandasai as pai; from pandasai_openai.openai import OpenAI; print(\"PandasAI ready!\")'"

EOF

# 설정 재로드
source ~/.zshrc

# 사용 예시
pai-setup           # 새 프로젝트 환경 설정
pai-env             # 가상환경 활성화
pai-test            # 기본 테스트 실행
pai-notebook        # Jupyter 노트북 실행
```

## 고급 활용 및 최적화

### ⚡ 성능 최적화

#### 대용량 데이터 처리
```python
import pandasai as pai
from pandasai_openai.openai import OpenAI

# 성능 최적화 설정
pai.config.set({
    "llm": OpenAI(model="gpt-3.5-turbo"),  # 빠른 모델 사용
    "enable_cache": True,  # 결과 캐싱 활성화
    "max_size_csv": 100_000,  # CSV 최대 행 수 제한
    "sample_size": 5000,  # 샘플링 크기 설정
})

# 대용량 데이터 샘플링
large_df = pai.read_csv('large_dataset.csv')
result = large_df.chat(
    "Analyze the key patterns in this dataset and provide insights",
    sample=True  # 자동 샘플링 활성화
)
```

#### 메모리 효율적 처리
```python
# 청크 단위 처리
def analyze_large_dataset(file_path, chunk_size=10000):
    insights = []
    
    for chunk in pd.read_csv(file_path, chunksize=chunk_size):
        df = pai.DataFrame(chunk)
        chunk_insight = df.chat(
            "Summarize the key metrics in this data chunk"
        )
        insights.append(chunk_insight)
    
    # 최종 통합 분석
    summary = "\n".join(insights)
    return summary
```

### 🔧 커스터마이징

#### 커스텀 LLM 설정
```python
# Azure OpenAI 사용
from pandasai_openai.azure_openai import AzureOpenAI

azure_llm = AzureOpenAI(
    azure_endpoint="your-azure-endpoint",
    api_key="your-azure-key",
    api_version="2024-02-15-preview",
    azure_deployment="your-deployment-name"
)

pai.config.set({"llm": azure_llm})

# Claude 사용 (Anthropic)
from pandasai_anthropic.claude import Claude

claude_llm = Claude(
    api_key="your-anthropic-key",
    model="claude-3-sonnet-20240229"
)

pai.config.set({"llm": claude_llm})
```

#### 커스텀 프롬프트 설정
```python
# 도메인 특화 프롬프트
custom_config = {
    "custom_head": """
    You are a financial data analyst AI. When analyzing data:
    1. Focus on business metrics and KPIs
    2. Provide actionable insights
    3. Include statistical significance when relevant
    4. Use business terminology appropriately
    """,
    "custom_instructions": """
    Always provide:
    - Executive summary
    - Key findings with numbers
    - Recommendations for action
    - Risk factors to consider
    """
}

pai.config.set(custom_config)
```

### 🛡️ 보안 및 거버넌스

#### 데이터 보안 설정
```python
# 민감한 데이터 마스킹
pai.config.set({
    "enable_data_masking": True,
    "sensitive_columns": ["ssn", "credit_card", "password"],
    "masking_character": "*"
})

# 쿼리 로깅 및 감사
pai.config.set({
    "enable_logging": True,
    "log_level": "INFO",
    "audit_queries": True,
    "log_file": "pandasai_audit.log"
})
```

#### 접근 권한 관리
```python
# 사용자 권한 기반 데이터 접근
class SecurePandasAI:
    def __init__(self, user_role):
        self.user_role = user_role
        self.configure_access()
    
    def configure_access(self):
        if self.user_role == "analyst":
            self.allowed_operations = ["read", "analyze", "visualize"]
        elif self.user_role == "admin":
            self.allowed_operations = ["read", "analyze", "visualize", "export"]
        else:
            self.allowed_operations = ["read"]
    
    def secure_chat(self, query, dataframe):
        if "export" in query.lower() and "export" not in self.allowed_operations:
            return "권한이 없습니다: 데이터 내보내기 권한이 필요합니다."
        
        return dataframe.chat(query)

# 사용 예시
secure_ai = SecurePandasAI("analyst")
result = secure_ai.secure_chat("Analyze sales trends", df)
```

## 문제해결 및 디버깅

### 🔍 일반적인 문제 해결

#### API 키 관련 문제
```python
import os
import pandasai as pai

def check_api_setup():
    """API 설정 확인 함수"""
    
    # 환경변수 확인
    api_key = os.getenv('OPENAI_API_KEY')
    if not api_key:
        print("❌ OPENAI_API_KEY 환경변수가 설정되지 않았습니다.")
        return False
    
    # API 키 형식 확인
    if not api_key.startswith('sk-'):
        print("❌ OpenAI API 키 형식이 올바르지 않습니다. 'sk-'로 시작해야 합니다.")
        return False
    
    # API 연결 테스트
    try:
        from pandasai_openai.openai import OpenAI
        llm = OpenAI()
        pai.config.set({"llm": llm})
        
        # 간단한 테스트
        test_df = pai.DataFrame({"test": [1, 2, 3]})
        result = test_df.chat("What is the sum of the test column?")
        print("✅ API 연결 성공")
        return True
        
    except Exception as e:
        print(f"❌ API 연결 실패: {e}")
        return False

# 설정 확인 실행
check_api_setup()
```

#### 메모리 부족 문제
```python
# 메모리 사용량 모니터링
import psutil
import pandas as pd

def monitor_memory_usage(func):
    """메모리 사용량 모니터링 데코레이터"""
    def wrapper(*args, **kwargs):
        process = psutil.Process()
        mem_before = process.memory_info().rss / 1024 / 1024  # MB
        
        result = func(*args, **kwargs)
        
        mem_after = process.memory_info().rss / 1024 / 1024  # MB
        print(f"메모리 사용량: {mem_before:.1f}MB → {mem_after:.1f}MB (증가: {mem_after-mem_before:.1f}MB)")
        
        return result
    return wrapper

@monitor_memory_usage
def analyze_large_data():
    large_df = pai.read_csv('large_file.csv')
    return large_df.chat("Provide summary statistics")
```

#### 성능 최적화 디버깅
```python
import time
import logging

# 상세 로깅 설정
logging.basicConfig(level=logging.DEBUG)
pai.config.set({
    "verbose": True,
    "debug": True
})

def time_analysis(query, dataframe):
    """분석 시간 측정"""
    start_time = time.time()
    
    result = dataframe.chat(query)
    
    end_time = time.time()
    execution_time = end_time - start_time
    
    print(f"쿼리 실행 시간: {execution_time:.2f}초")
    print(f"결과: {result}")
    
    return result, execution_time

# 사용 예시
df = pai.DataFrame({"sales": range(1000), "region": ["A", "B"] * 500})
result, time_taken = time_analysis("What is the average sales by region?", df)
```

## 결론

**PandasAI**는 데이터 분석의 진입 장벽을 크게 낮추는 혁신적인 도구입니다. 복잡한 pandas 코드나 SQL 쿼리를 작성할 필요 없이, **자연어로 질문하기만 하면 AI가 데이터를 분석하고 인사이트를 제공**합니다.

### 🎯 핵심 가치 요약

1. **접근성**: 비전문가도 쉽게 데이터 분석 가능
2. **효율성**: 복잡한 분석도 몇 분 안에 완료
3. **안전성**: Docker 샌드박스로 보안 강화
4. **확장성**: 다양한 LLM과 데이터 소스 지원
5. **실용성**: 실제 비즈니스 문제 해결에 즉시 활용

### 🚀 활용 분야

- **비즈니스 인텔리전스**: 매출, 고객, 운영 데이터 분석
- **데이터 과학**: 탐색적 데이터 분석 및 가설 검정
- **교육**: 데이터 분석 학습 및 교육 도구
- **연구**: 빠른 프로토타이핑 및 인사이트 발견

### 💡 성공을 위한 팁

1. **명확한 질문**: 구체적이고 명확한 질문일수록 정확한 답변
2. **데이터 품질**: 깨끗하고 구조화된 데이터가 더 나은 결과 생성
3. **반복적 접근**: 첫 번째 질문 결과를 바탕으로 후속 질문 진행
4. **결과 검증**: AI 결과를 항상 비판적으로 검토하고 검증

지금 바로 [PandasAI GitHub 프로젝트](https://github.com/sinaptik-ai/pandas-ai)를 확인하고, 여러분의 데이터 분석 워크플로우에 PandasAI를 도입해보세요! 🚀

---

**관련 링크:**
- [PandasAI GitHub Repository](https://github.com/sinaptik-ai/pandas-ai)
- [공식 웹사이트](https://pandas-ai.com)
- [공식 문서](https://docs.pandas-ai.com)
- [OpenAI API Keys](https://platform.openai.com/api-keys)
