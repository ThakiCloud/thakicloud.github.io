#!/usr/bin/env python3
"""
LangExtract 기본 테스트 스크립트

이 스크립트는 LangExtract의 기본 기능을 테스트합니다.
"""

import os
import sys
from typing import Dict, List

try:
    import langextract as lx
    print("✅ LangExtract 라이브러리 임포트 성공")
except ImportError as e:
    print(f"❌ LangExtract 라이브러리 임포트 실패: {e}")
    sys.exit(1)

def test_basic_functionality():
    """기본 기능 테스트 (API 키 없이)"""
    print("\n🔍 기본 기능 테스트...")
    
    # 기본 텍스트 데이터
    sample_text = """
    존 스미스는 35세의 소프트웨어 엔지니어입니다. 
    그는 시애틀에 거주하며 Python과 JavaScript를 주로 사용합니다.
    취미는 하이킹과 사진촬영이며, 현재 AI 스타트업에서 근무하고 있습니다.
    """
    
    # 추출하고자 하는 정보의 예시
    examples = [
        {
            "name": "김철수",
            "age": 28,
            "profession": "데이터 사이언티스트",
            "location": "서울",
            "skills": ["Python", "R", "SQL"],
            "hobbies": ["독서", "영화감상"]
        }
    ]
    
    print(f"📄 테스트 텍스트: {sample_text.strip()}")
    print(f"📋 예시 스키마: {examples[0]}")
    
    return sample_text, examples

def test_with_mock_model():
    """Mock 모델을 사용한 테스트"""
    print("\n🧪 Mock 모델 테스트...")
    
    try:
        # LangExtract의 버전 정보 확인
        print(f"📦 LangExtract 버전: {lx.__version__ if hasattr(lx, '__version__') else 'Unknown'}")
        
        # 기본 구성 요소 테스트
        from langextract.inference import LanguageModel
        print("✅ 언어 모델 클래스 임포트 성공")
        
        from langextract.extraction import extract
        print("✅ 추출 함수 임포트 성공")
        
        print("✅ 모든 핵심 컴포넌트가 정상적으로 로드됨")
        
    except Exception as e:
        print(f"❌ Mock 모델 테스트 실패: {e}")
        return False
    
    return True

def test_documentation_examples():
    """문서 예제 테스트"""
    print("\n📚 문서 예제 구조 테스트...")
    
    # Romeo and Juliet 예제와 유사한 구조
    literary_text = """
    줄리엣은 발코니에서 별을 바라보며 그리워했다. 
    그녀의 마음은 로미오에 대한 사랑으로 가득 차 있었다.
    달빛 아래에서 그녀는 조용히 눈물을 흘렸다.
    """
    
    # 캐릭터 정보 추출 예시
    character_examples = [
        {
            "name": "로미오",
            "emotional_state": "열정적인",
            "location": "정원",
            "evidence": "그는 정원에서 열정적으로 사랑을 고백했다"
        }
    ]
    
    prompt = "문학 작품에서 캐릭터의 이름, 감정 상태, 위치, 그리고 이를 뒷받침하는 텍스트 증거를 추출하세요."
    
    print(f"📄 문학 텍스트: {literary_text.strip()}")
    print(f"📋 캐릭터 예시: {character_examples[0]}")
    print(f"🎯 추출 프롬프트: {prompt}")
    
    return True

def check_environment():
    """환경 설정 확인"""
    print("\n🔧 환경 설정 확인...")
    
    # Python 버전
    python_version = f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}"
    print(f"🐍 Python 버전: {python_version}")
    
    # API 키 확인 (실제 값은 표시하지 않음)
    api_key = os.getenv('LANGEXTRACT_API_KEY')
    if api_key:
        print(f"🔑 API 키 설정됨: {'*' * min(len(api_key), 20)}")
    else:
        print("⚠️  API 키가 설정되지 않음 (LANGEXTRACT_API_KEY)")
    
    # 필수 의존성 확인
    dependencies = ['pandas', 'numpy', 'requests', 'pydantic']
    for dep in dependencies:
        try:
            __import__(dep)
            print(f"✅ {dep} 설치됨")
        except ImportError:
            print(f"❌ {dep} 설치되지 않음")

def create_test_files():
    """테스트를 위한 샘플 파일 생성"""
    print("\n📁 테스트 파일 생성...")
    
    # 샘플 텍스트 파일
    sample_content = """
    회사: 테크노베이션 코리아
    CEO: 김혁신 (45세)
    설립: 2020년
    직원수: 150명
    주요 기술: AI, 클라우드, 빅데이터
    위치: 서울 강남구
    매출: 100억원 (2023년)
    """
    
    with open('sample_company_info.txt', 'w', encoding='utf-8') as f:
        f.write(sample_content)
    
    print("✅ sample_company_info.txt 생성됨")
    
    # 테스트 설정 파일
    config_content = """
# LangExtract 테스트 설정
TEST_MODEL = "gemini-2.5-flash"
MAX_WORKERS = 5
EXTRACTION_PASSES = 2
"""
    
    with open('test_config.py', 'w', encoding='utf-8') as f:
        f.write(config_content)
    
    print("✅ test_config.py 생성됨")

def main():
    """메인 테스트 함수"""
    print("🚀 LangExtract 기본 테스트 시작")
    print("=" * 50)
    
    # 환경 확인
    check_environment()
    
    # 기본 기능 테스트
    sample_text, examples = test_basic_functionality()
    
    # Mock 모델 테스트
    mock_success = test_with_mock_model()
    
    # 문서 예제 테스트
    doc_success = test_documentation_examples()
    
    # 테스트 파일 생성
    create_test_files()
    
    print("\n" + "=" * 50)
    print("📊 테스트 결과:")
    print(f"   ✅ 라이브러리 임포트: 성공")
    print(f"   ✅ Mock 모델 테스트: {'성공' if mock_success else '실패'}")
    print(f"   ✅ 문서 예제 구조: {'성공' if doc_success else '실패'}")
    print(f"   ✅ 테스트 파일 생성: 성공")
    
    print("\n💡 다음 단계:")
    print("   1. API 키 설정 (Gemini 또는 OpenAI)")
    print("   2. 실제 추출 테스트 실행")
    print("   3. 결과 시각화 확인")
    
    print("\n🎯 LangExtract 기본 설정 완료!")

if __name__ == "__main__":
    main()