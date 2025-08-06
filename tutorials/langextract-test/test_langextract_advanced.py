#!/usr/bin/env python3
"""
LangExtract 고급 사용법 테스트

이 스크립트는 실제 API를 사용하지 않고도 LangExtract의 기능을 시연합니다.
"""

import os
import json
import sys
from typing import Dict, List, Any

try:
    import langextract as lx
    print("✅ LangExtract 라이브러리 임포트 성공")
except ImportError as e:
    print(f"❌ LangExtract 라이브러리 임포트 실패: {e}")
    sys.exit(1)

# 한국어 샘플 데이터
SAMPLE_TEXTS = {
    "medical": """
    환자: 김영희 (65세, 여성)
    진단: 고혈압, 당뇨병
    처방약: 
    - 로사르탄 50mg, 1일 1회 아침 식후 복용
    - 메트포르민 500mg, 1일 2회 식후 복용
    - 아스피린 100mg, 1일 1회 저녁 식후 복용
    다음 진료 예약: 2024년 2월 15일
    """,
    
    "business": """
    회사명: (주)디지털이노베이션
    대표이사: 박창신 (52세)
    설립일: 2019년 3월 15일
    주소: 서울특별시 강남구 테헤란로 123
    사업분야: AI 솔루션 개발, 클라우드 서비스
    직원수: 85명
    연매출: 120억원 (2023년 기준)
    주요 고객: 삼성전자, LG전자, 네이버
    """,
    
    "academic": """
    논문 제목: "딥러닝을 활용한 자연어 처리 성능 향상 연구"
    저자: 이민수, 김데이터, 박알고리즘
    소속: 서울대학교 컴퓨터공학부
    발표일: 2024년 1월 20일
    학회: 한국정보과학회 동계학술대회
    키워드: 딥러닝, 자연어처리, BERT, 한국어, 성능최적화
    """,
    
    "news": """
    [속보] AI 스타트업 '브레인테크', 200억원 시리즈 B 투자 유치
    
    인공지능 기술 전문 스타트업 브레인테크(대표 최혁신)가 글로벌 벤처캐피털로부터 
    200억원 규모의 시리즈 B 투자를 유치했다고 8일 발표했다.
    
    이번 투자에는 실리콘밸리의 ABC벤처스, 국내 대기업 계열 CVC인 테크인베스트먼트 등이 참여했다.
    브레인테크는 2020년 설립 이후 자연어 처리와 컴퓨터 비전 분야에서 혁신적인 기술을 개발해왔다.
    """
}

# 추출 스키마 예시
EXTRACTION_SCHEMAS = {
    "medical": [
        {
            "patient_name": "홍길동",
            "age": 45,
            "gender": "남성",
            "diagnosis": ["고혈압"],
            "medications": [
                {
                    "name": "리시노프릴",
                    "dosage": "10mg",
                    "frequency": "1일 1회",
                    "timing": "아침 식후"
                }
            ],
            "next_appointment": "2024-01-30"
        }
    ],
    
    "business": [
        {
            "company_name": "테크솔루션즈",
            "ceo": {
                "name": "김대표",
                "age": 48
            },
            "establishment_date": "2020-05-10",
            "address": "부산광역시 해운대구 센텀로 99",
            "business_fields": ["소프트웨어 개발", "IT 컨설팅"],
            "employee_count": 120,
            "annual_revenue": "80억원",
            "major_clients": ["현대자동차", "포스코"]
        }
    ],
    
    "academic": [
        {
            "title": "머신러닝 기반 예측 모델 연구",
            "authors": ["김연구", "이논문"],
            "affiliation": "KAIST 전산학부",
            "publication_date": "2024-03-15",
            "conference": "한국컴퓨터종합학술대회",
            "keywords": ["머신러닝", "예측모델", "데이터분석"]
        }
    ],
    
    "news": [
        {
            "headline": "스타트업 투자 유치 소식",
            "company": "이노베이션랩",
            "ceo": "박창업",
            "investment_amount": "150억원",
            "investment_round": "시리즈 A",
            "investors": ["코리아벤처스", "스타트업펀드"],
            "establishment_year": 2021,
            "business_area": ["핀테크", "블록체인"]
        }
    ]
}

def demonstrate_extraction_structure():
    """추출 구조 시연"""
    print("\n🏗️  추출 구조 시연")
    print("=" * 50)
    
    for category, text in SAMPLE_TEXTS.items():
        print(f"\n📂 카테고리: {category.upper()}")
        print(f"📄 텍스트 길이: {len(text)} 글자")
        print(f"📋 추출 스키마 예시:")
        
        schema = EXTRACTION_SCHEMAS[category][0]
        print(json.dumps(schema, ensure_ascii=False, indent=2))
        
        print(f"📝 원본 텍스트:")
        print(text.strip())
        print("-" * 30)

def simulate_extraction_process():
    """추출 과정 시뮬레이션"""
    print("\n🔄 추출 과정 시뮬레이션")
    print("=" * 50)
    
    # 의료 텍스트 예시로 시뮬레이션
    medical_text = SAMPLE_TEXTS["medical"]
    medical_schema = EXTRACTION_SCHEMAS["medical"][0]
    
    print("📋 추출 설정:")
    print(f"   • 모델: gemini-2.5-flash (시뮬레이션)")
    print(f"   • 추출 패스: 2회")
    print(f"   • 최대 작업자: 5개")
    print(f"   • 텍스트 버퍼: 1000글자")
    
    print("\n🎯 추출 프롬프트:")
    prompt = """
    의료 기록에서 다음 정보를 추출하세요:
    - 환자 정보 (이름, 나이, 성별)
    - 진단명
    - 처방 약물 (이름, 용량, 복용법)
    - 예약 정보
    """
    print(prompt)
    
    print("\n📊 시뮬레이션 결과:")
    simulated_result = {
        "patient_name": "김영희",
        "age": 65,
        "gender": "여성",
        "diagnosis": ["고혈압", "당뇨병"],
        "medications": [
            {
                "name": "로사르탄",
                "dosage": "50mg",
                "frequency": "1일 1회",
                "timing": "아침 식후"
            },
            {
                "name": "메트포르민",
                "dosage": "500mg",
                "frequency": "1일 2회",
                "timing": "식후"
            },
            {
                "name": "아스피린",
                "dosage": "100mg",
                "frequency": "1일 1회",
                "timing": "저녁 식후"
            }
        ],
        "next_appointment": "2024-02-15"
    }
    
    print(json.dumps(simulated_result, ensure_ascii=False, indent=2))

def demonstrate_visualization_concept():
    """시각화 개념 설명"""
    print("\n🎨 시각화 기능 개념")
    print("=" * 50)
    
    print("LangExtract는 추출된 결과를 다음과 같이 시각화합니다:")
    print("\n1. 📄 원본 텍스트 표시")
    print("   • 추출된 부분이 하이라이트됨")
    print("   • 색상별로 엔티티 구분")
    
    print("\n2. 🏷️  추출된 엔티티 목록")
    print("   • 구조화된 데이터 형태로 표시")
    print("   • 원본 텍스트와 연결된 증거 포함")
    
    print("\n3. 🔗 상호작용 기능")
    print("   • 엔티티 클릭 시 원본 위치로 이동")
    print("   • 필터링 및 검색 기능")
    print("   • JSON/CSV 내보내기")
    
    # 시각화 HTML 구조 예시
    html_example = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>LangExtract 결과 시각화</title>
        <style>
            .entity-person { background-color: #ffeb3b; }
            .entity-medication { background-color: #4caf50; }
            .entity-date { background-color: #2196f3; }
        </style>
    </head>
    <body>
        <div class="text-display">
            환자: <span class="entity-person">김영희</span> (65세, 여성)
            처방약: <span class="entity-medication">로사르탄 50mg</span>
            예약: <span class="entity-date">2024년 2월 15일</span>
        </div>
        <div class="entities-list">
            <!-- 추출된 엔티티 목록 -->
        </div>
    </body>
    </html>
    """
    
    print("\n📝 HTML 시각화 예시 구조:")
    print(html_example)

def create_test_scripts():
    """실제 사용을 위한 테스트 스크립트 생성"""
    print("\n📝 테스트 스크립트 생성")
    print("=" * 50)
    
    # 실제 API 테스트 스크립트
    api_test_script = '''#!/usr/bin/env python3
"""
LangExtract API 테스트 스크립트
실제 API 키를 설정한 후 실행하세요.
"""

import os
import langextract as lx

def test_with_api():
    """실제 API를 사용한 테스트"""
    
    # API 키 확인
    api_key = os.getenv('LANGEXTRACT_API_KEY')
    if not api_key:
        print("❌ LANGEXTRACT_API_KEY 환경변수를 설정하세요")
        return
    
    # 테스트 텍스트
    text = """
    김철수는 30세의 데이터 사이언티스트입니다.
    서울에 거주하며 Python, R, SQL을 다룹니다.
    현재 핀테크 회사에서 ML 엔지니어로 근무 중입니다.
    """
    
    # 추출 예시
    examples = [
        {
            "name": "박영희",
            "age": 28,
            "profession": "소프트웨어 엔지니어",
            "location": "부산",
            "skills": ["Java", "Spring", "React"]
        }
    ]
    
    # 추출 실행
    try:
        result = lx.extract(
            text_or_documents=text,
            prompt_description="인물 정보를 추출하세요",
            examples=examples,
            model_id="gemini-2.5-flash"
        )
        
        print("✅ 추출 성공!")
        print("결과:", result)
        
        # 결과 저장
        lx.io.save_annotated_documents(
            [result], 
            output_name="test_results.jsonl", 
            output_dir="."
        )
        
        # 시각화 생성
        html_content = lx.visualize("test_results.jsonl")
        with open("test_visualization.html", "w", encoding="utf-8") as f:
            f.write(html_content)
        
        print("✅ 시각화 파일 생성: test_visualization.html")
        
    except Exception as e:
        print(f"❌ 추출 실패: {e}")

if __name__ == "__main__":
    test_with_api()
'''
    
    with open('test_api_usage.py', 'w', encoding='utf-8') as f:
        f.write(api_test_script)
    
    print("✅ test_api_usage.py 생성됨")
    
    # 설치 스크립트
    install_script = '''#!/bin/bash
# LangExtract 설치 및 설정 스크립트

echo "🚀 LangExtract 설치 시작"

# 가상환경 생성 (선택사항)
read -p "가상환경을 생성하시겠습니까? (y/n): " create_venv
if [ "$create_venv" = "y" ]; then
    python -m venv langextract_env
    source langextract_env/bin/activate
    echo "✅ 가상환경 생성 및 활성화 완료"
fi

# LangExtract 설치
pip install langextract

# API 키 설정 가이드
echo ""
echo "🔑 API 키 설정이 필요합니다:"
echo "1. Gemini API: https://ai.google.dev/"
echo "2. OpenAI API: https://platform.openai.com/"
echo ""
echo "API 키를 받은 후 다음 중 하나를 선택하세요:"
echo ""
echo "방법 1: 환경변수 설정"
echo "export LANGEXTRACT_API_KEY='your-api-key'"
echo ""
echo "방법 2: .env 파일 생성"
echo "echo 'LANGEXTRACT_API_KEY=your-api-key' > .env"
echo ""

# 테스트 실행
echo "📋 설치 확인 테스트 실행..."
python test_langextract_basic.py

echo "✅ LangExtract 설치 완료!"
'''
    
    with open('install_langextract.sh', 'w', encoding='utf-8') as f:
        f.write(install_script)
    
    os.chmod('install_langextract.sh', 0o755)
    print("✅ install_langextract.sh 생성됨 (실행권한 부여)")

def generate_zshrc_aliases():
    """zshrc aliases 생성"""
    print("\n⚡ zshrc Aliases 가이드")
    print("=" * 50)
    
    aliases = '''
# LangExtract 관련 aliases
alias lx-install="pip install langextract"
alias lx-test="python test_langextract_basic.py"
alias lx-api-test="python test_api_usage.py"
alias lx-demo="python test_langextract_advanced.py"

# API 키 설정 helper
alias lx-setkey="echo 'export LANGEXTRACT_API_KEY=your-api-key-here' >> ~/.zshrc && source ~/.zshrc"

# 결과 파일 관리
alias lx-results="ls -la *.jsonl *.html"
alias lx-clean="rm -f *.jsonl *.html test_*.py"

# 가상환경 관리
alias lx-venv="python -m venv langextract_env && source langextract_env/bin/activate"
alias lx-activate="source langextract_env/bin/activate"
'''
    
    print("다음 aliases를 ~/.zshrc에 추가하세요:")
    print(aliases)
    
    # aliases 파일로 저장
    with open('langextract_aliases.sh', 'w', encoding='utf-8') as f:
        f.write(aliases)
    
    print("✅ langextract_aliases.sh 파일로 저장됨")

def main():
    """메인 함수"""
    print("🔬 LangExtract 고급 기능 테스트")
    print("=" * 60)
    
    # 추출 구조 시연
    demonstrate_extraction_structure()
    
    # 추출 과정 시뮬레이션  
    simulate_extraction_process()
    
    # 시각화 개념 설명
    demonstrate_visualization_concept()
    
    # 테스트 스크립트 생성
    create_test_scripts()
    
    # zshrc aliases 생성
    generate_zshrc_aliases()
    
    print("\n" + "=" * 60)
    print("🎯 고급 테스트 완료!")
    print("\n📁 생성된 파일:")
    print("   • test_api_usage.py - 실제 API 테스트")
    print("   • install_langextract.sh - 설치 스크립트")
    print("   • langextract_aliases.sh - zshrc aliases")
    
    print("\n💡 다음 단계:")
    print("   1. API 키 설정")
    print("   2. test_api_usage.py 실행")
    print("   3. 시각화 결과 확인")

if __name__ == "__main__":
    main()